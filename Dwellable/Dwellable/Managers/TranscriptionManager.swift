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
    @Published var audioURL: String?  // Cloud URL of saved audio (from Supabase Storage)

    private var whisperKit: WhisperKit?
    private(set) var isModelLoaded: Bool = false

    /// Public read-only flag — true once model is downloaded and loaded
    var isModelReady: Bool { isModelLoaded && whisperKit != nil }
    private var transcriptionStartTime: Date?
    private var temporaryAudioURL: URL?
    private var currentTask: Task<Void, Never>?

    // Dependencies for audio upload
    var apiClient: APIClient?
    var userId: String?

    override init() {
        super.init()
    }

    /// Set the API client and user ID for audio uploads
    func setAPIClient(_ client: APIClient, userId: String) {
        self.apiClient = client
        self.userId = userId
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

        // Check minimum file size (at least 2KB for meaningful audio)
        // Files under 2KB are likely silence or noise
        return fileSize.intValue >= 2000
    }

    /// Check if audio file appears to be blank/silent by analyzing metadata
    private func hasAudioContent(url: URL) -> Bool {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration.seconds

        // Duration must be at least 1.5 seconds for meaningful content
        guard duration >= 1.5 else {
            hlog("Audio duration too short: \(String(format: "%.1f", duration))s (need >= 1.5s)", "WARNING")
            return false
        }

        // Check file size relative to duration
        // Normal speech at 16kHz is ~32KB per second
        // Very small files relative to duration suggest silence
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.size] as? Int ?? 0
        let expectedMinSize = Int(duration * 20000) // ~20KB per second minimum

        if fileSize < expectedMinSize {
            hlog("Audio file too small for duration: \(fileSize) bytes for \(String(format: "%.1f", duration))s (expected >= \(expectedMinSize))", "WARNING")
            return false
        }

        return true
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

        // Log audio duration for diagnostic purposes
        let asset = AVURLAsset(url: fileURL)
        let durationSec = asset.duration.seconds
        let durationFormatted = durationSec.isFinite ? String(format: "%.1fs", durationSec) : "unknown"
        hlog("Audio file: \(String(format: "%.1f", sizeKB)) KB, duration: \(durationFormatted)")

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

                // Strip any [BLANK_AUDIO] markers that WhisperKit appends to valid transcriptions
                let cleanedText = fullText
                    .replacingOccurrences(of: " [BLANK_AUDIO]", with: "")
                    .replacingOccurrences(of: "[BLANK_AUDIO] ", with: "")
                    .replacingOccurrences(of: "[BLANK_AUDIO]", with: "")
                    .trimmingCharacters(in: .whitespaces)

                let elapsed = self.transcriptionStartTime.map { Date().timeIntervalSince($0) } ?? 0
                let segmentCount = results.count
                let wordCount = cleanedText.split(separator: " ").count

                // Diagnostic: log segment breakdown for accuracy investigation
                hlog("WhisperKit: \(segmentCount) segment(s), \(wordCount) words, processed in \(String(format: "%.1f", elapsed))s")
                for (i, result) in results.enumerated() {
                    let segText = result.text.trimmingCharacters(in: .whitespaces)
                    let segWords = segText.split(separator: " ").count
                    hlog("  Segment \(i + 1)/\(segmentCount): \(segWords) words — \"\(String(segText.prefix(80)))\"")
                }

                await MainActor.run {
                    self.isTranscribing = false
                    self.transcriptionProgress = ""

                    // Reject if empty, whitespace-only, blank audio marker, or too short
                    let isBlankAudio = cleanedText.isEmpty
                    let isTooShort = wordCount < 2 // Require at least 2 words

                    if isBlankAudio || isTooShort {
                        let reason = isBlankAudio ? "blank audio" : "too short (\(wordCount) word\(wordCount == 1 ? "" : "s"))"
                        hlog("WhisperKit: rejected — \(reason) after \(String(format: "%.1f", elapsed))s", "WARNING")
                        self.transcript = "" // Clear transcript so ReviewView knows it's invalid
                        self.errorMessage = "Dwellable didn't catch that. Feel free to speak again."
                        self.deleteTemporaryAudioFile()
                        completion(nil)
                    } else {
                        self.transcript = cleanedText
                        hlog("WhisperKit: complete — \(wordCount) words, \(cleanedText.count) chars in \(String(format: "%.1f", elapsed))s", "SUCCESS")
                        hlog("Preview: \"\(String(cleanedText.prefix(120)))\"")
                    }
                }

                // Upload audio to Supabase Storage (happens AFTER transcription completes)
                // Skip upload if transcription was rejected (transcript will be empty)
                if !self.transcript.isEmpty {
                    if let tempURL = self.temporaryAudioURL, let apiClient = self.apiClient, let userId = self.userId {
                        do {
                            let audioData = try Data(contentsOf: tempURL)
                            let fileName = "moment_\(UUID().uuidString).m4a"
                            let publicURL = try await apiClient.uploadAudio(audioData, fileName: fileName, userId: userId)
                            await MainActor.run {
                                self.audioURL = publicURL
                                hlog("Audio uploaded to Storage: \(fileName)", "SUCCESS")
                            }
                        } catch {
                            hlog("Failed to upload audio, but transcription succeeded: \(error.localizedDescription)", "WARNING")
                            await MainActor.run {
                                self.audioURL = nil
                            }
                        }
                        // Clean up temp file after upload attempt
                        try? FileManager.default.removeItem(at: tempURL)
                    } else {
                        hlog("No API client or user ID available for audio upload", "WARNING")
                    }
                    // Now call completion after audio upload attempt is done
                    await MainActor.run {
                        hlog("About to call completion — audioURL is: \(self.audioURL ?? "nil")", "INFO")
                        completion(fullText)
                    }
                } else {
                    // No transcription, clean up
                    self.deleteTemporaryAudioFile()
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
