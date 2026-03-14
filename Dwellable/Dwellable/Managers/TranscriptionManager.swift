import Foundation
import WhisperKit
import Combine
import AVFoundation

private func hlog(_ msg: String, _ level: String = "INFO") {
    print("[\(level)] \(msg)")
    HTMLLogManager.shared.log(msg, level: level)
}

class TranscriptionManager: NSObject, ObservableObject {
    static let shared = TranscriptionManager()

    @Published var transcript: String = ""
    @Published var isTranscribing: Bool = false
    @Published var errorMessage: String?
    @Published var isIncompleteTranscription: Bool = false
    @Published var transcriptionProgress: String = ""

    private var whisperKit: WhisperKit?
    private(set) var isModelLoaded: Bool = false

    /// Public read-only flag — true once model is downloaded and loaded
    var isModelReady: Bool { isModelLoaded && whisperKit != nil }
    private var transcriptionStartTime: Date?
    private var temporaryAudioURL: URL?
    private var currentTask: Task<Void, Never>?

    override init() {
        super.init()
    }

    // MARK: - WhisperKit Setup

    func setupWhisperKit() async {
        guard whisperKit == nil else {
            hlog("WhisperKit: already loaded, skipping init")
            return
        }

        do {
            // "base" (~74MB) — fast download, reliable accuracy for voice memos
            // "small" (~244MB) — higher accuracy if needed in future
            hlog("WhisperKit: downloading/loading base model (~74MB)...")
            let config = WhisperKitConfig(model: "base", verbose: false, load: true, download: true)
            whisperKit = try await WhisperKit(config)
            isModelLoaded = true
            hlog("WhisperKit: base model ready ✓", "SUCCESS")
        } catch {
            hlog("WhisperKit: failed to initialize — \(error.localizedDescription)", "ERROR")
            whisperKit = nil
            isModelLoaded = false
        }
    }

    // MARK: - File Validation

    private func isValidAudioFile(url: URL) -> Bool {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else { return false }
        let fileAttributes = try? fileManager.attributesOfItem(atPath: url.path)
        let fileSize = fileAttributes?[.size] as? NSNumber ?? 0
        return fileSize.intValue >= 5000
    }

    // MARK: - Public API

    func transcribeAudio(from fileURL: URL, completion: @escaping (String?) -> Void) {
        isTranscribing = true
        errorMessage = nil
        transcript = ""
        transcriptionProgress = ""
        isIncompleteTranscription = false
        transcriptionStartTime = Date()
        temporaryAudioURL = fileURL

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path))?[.size] as? Int ?? 0
        let sizeKB = Double(fileSize) / 1024.0
        hlog("Transcription start — \(fileURL.lastPathComponent), \(String(format: "%.1f", sizeKB)) KB")

        if !isValidAudioFile(url: fileURL) {
            hlog("File validation failed — \(String(format: "%.1f", sizeKB)) KB (too small or missing)", "ERROR")
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.errorMessage = "That was too quick. Try speaking for a bit longer and we'll catch it."
                completion(nil)
            }
            return
        }

        hlog("File validation passed")

        currentTask = Task { [weak self] in
            guard let self = self else { return }

            if !self.isModelLoaded {
                await MainActor.run { self.transcriptionProgress = "Loading transcription model..." }
                hlog("WhisperKit: model not ready yet — loading now...", "WARNING")
                await self.setupWhisperKit()
            }

            guard self.whisperKit != nil else {
                hlog("WhisperKit: model still nil after load attempt — aborting", "ERROR")
                await MainActor.run {
                    self.isTranscribing = false
                    self.errorMessage = "Transcription model failed to load. Please restart the app and try again."
                    completion(nil)
                }
                return
            }

            await MainActor.run { self.transcriptionProgress = "Transcribing your moment..." }
            hlog("WhisperKit: starting transcription of \(fileURL.lastPathComponent)")

            do {
                let options = DecodingOptions(verbose: false, task: .transcribe, language: "en")
                let results = try await self.whisperKit!.transcribe(audioPath: fileURL.path, decodeOptions: options)

                if Task.isCancelled {
                    hlog("WhisperKit: transcription cancelled mid-flight", "WARNING")
                    await MainActor.run {
                        self.isTranscribing = false
                        self.isIncompleteTranscription = true
                        completion(nil)
                    }
                    return
                }

                let fullText = results.map { $0.text }.joined(separator: " ").trimmingCharacters(in: .whitespaces)
                let elapsed = self.transcriptionStartTime.map { Date().timeIntervalSince($0) } ?? 0

                await MainActor.run {
                    self.isTranscribing = false
                    self.transcriptionProgress = ""
                    self.deleteTemporaryAudioFile()

                    if fullText.isEmpty {
                        hlog("WhisperKit: empty result after \(String(format: "%.1f", elapsed))s", "WARNING")
                        self.errorMessage = "Dwellable didn't catch that. Feel free to speak again."
                        completion(nil)
                    } else {
                        self.transcript = fullText
                        hlog("WhisperKit: complete — \(fullText.count) chars in \(String(format: "%.1f", elapsed))s", "SUCCESS")
                        hlog("Preview: \"\(String(fullText.prefix(120)))\"")
                        completion(fullText)
                    }
                }
            } catch {
                let elapsed = self.transcriptionStartTime.map { Date().timeIntervalSince($0) } ?? 0
                hlog("WhisperKit: error after \(String(format: "%.1f", elapsed))s — \(error.localizedDescription)", "ERROR")
                await MainActor.run {
                    self.isTranscribing = false
                    self.transcriptionProgress = ""
                    self.deleteTemporaryAudioFile()
                    self.handleTranscriptionError(error)
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Error Handling

    private func handleTranscriptionError(_ error: Error) {
        let description = error.localizedDescription.lowercased()

        if description.contains("permission") {
            errorMessage = "Speech recognition is disabled. Enable it in Settings to continue."
        } else if description.contains("network") || description.contains("connection") {
            errorMessage = "Can't reach the server. Check your connection and try again."
        } else if description.contains("memory") {
            errorMessage = "That recording was too large to process. Try a shorter recording."
        } else {
            errorMessage = "Dwellable didn't catch your capture. Feel free to articulate again or speak it once more."
        }

        hlog("Error shown to user: \(errorMessage ?? "unknown")", "ERROR")
    }

    // MARK: - Cancel & Cleanup

    func cancelTranscription() {
        currentTask?.cancel()
        currentTask = nil
        isTranscribing = false
        transcriptionProgress = ""

        if !transcript.trimmingCharacters(in: .whitespaces).isEmpty {
            isIncompleteTranscription = true
            hlog("Transcription cancelled — partial transcript preserved (\(transcript.count) chars)", "WARNING")
        } else {
            transcript = ""
            hlog("Transcription cancelled — no partial content", "WARNING")
        }

        errorMessage = nil
        deleteTemporaryAudioFile()
    }

    private func deleteTemporaryAudioFile() {
        guard let audioURL = temporaryAudioURL else { return }
        do {
            try FileManager.default.removeItem(at: audioURL)
            hlog("Cleanup: deleted \(audioURL.lastPathComponent)", "SUCCESS")
            temporaryAudioURL = nil
        } catch {
            hlog("Cleanup: failed to delete \(audioURL.lastPathComponent) — \(error.localizedDescription)", "WARNING")
        }
    }
}
