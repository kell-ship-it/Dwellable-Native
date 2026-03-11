import Foundation
import Speech
import Combine
import AVFoundation

class TranscriptionManager: NSObject, ObservableObject {
    @Published var transcript: String = ""
    @Published var isTranscribing: Bool = false
    @Published var errorMessage: String?

    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var transcriptionTimeoutTimer: Timer?

    private static let TRANSCRIPTION_TIMEOUT: TimeInterval = 60 // 60 second safety timeout

    override init() {
        super.init()
        requestSpeechRecognitionPermission()
    }

    private func isValidAudioFile(url: URL) -> Bool {
        do {
            // Check file exists and has content (at least 5KB to ensure it's not just a header)
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: url.path) else {
                return false
            }

            let fileAttributes = try fileManager.attributesOfItem(atPath: url.path)
            let fileSize = fileAttributes[.size] as? NSNumber ?? 0

            // Minimum 5KB to ensure the file has actual audio data
            guard fileSize.intValue >= 5000 else {
                return false
            }

            let asset = AVAsset(url: url)
            let duration = asset.duration

            // Reject audio shorter than 0.5 seconds to prevent empty audio crashes
            let durationSeconds = duration.seconds

            // Check for valid audio: minimum 0.5 seconds, not NaN, and finite
            let isValid = durationSeconds >= 0.5 && !durationSeconds.isNaN && durationSeconds.isFinite
            return isValid
        } catch {
            // If anything fails (file access error, etc.), treat as invalid audio
            return false
        }
    }

    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    // B-012 Fix: Clear error message when permission is granted
                    self.errorMessage = nil
                case .denied, .restricted:
                    self.errorMessage = "Speech recognition is disabled. Enable it in Settings to use voice capture."
                case .notDetermined:
                    break
                @unknown default:
                    self.errorMessage = "Please check your speech recognition settings."
                }
            }
        }
    }

    func transcribeAudio(from fileURL: URL, completion: @escaping (String?) -> Void) {
        isTranscribing = true
        errorMessage = nil
        transcript = ""

        // VALIDATE AUDIO BEFORE TRANSCRIPTION (B-002 Fix)
        // Prevent crashes from empty or too-short audio files
        if !isValidAudioFile(url: fileURL) {
            DispatchQueue.main.async {
                self.isTranscribing = false
                self.errorMessage = "That was too quick. Try speaking for a bit longer and we'll catch it."
                completion(nil)
            }
            return
        }

        // Set up timeout safety net
        transcriptionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.TRANSCRIPTION_TIMEOUT, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                if self?.isTranscribing == true {
                    self?.errorMessage = "That took a moment. Try again with a shorter recording."
                    self?.isTranscribing = false
                    self?.recognitionTask?.cancel()
                    completion(nil)
                }
            }
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Audio setup encountered an issue. Try again in a moment."
                self.isTranscribing = false
                self.transcriptionTimeoutTimer?.invalidate()
                self.transcriptionTimeoutTimer = nil
                completion(nil)
            }
            return
        }

        let recognitionRequest = SFSpeechURLRecognitionRequest(url: fileURL)
        recognitionRequest.shouldReportPartialResults = true

        if let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable {
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
                DispatchQueue.main.async {
                    if let result = result {
                        self.transcript = result.bestTranscription.formattedString

                        if result.isFinal {
                            self.isTranscribing = false
                            self.transcriptionTimeoutTimer?.invalidate()
                            self.transcriptionTimeoutTimer = nil

                            // Handle empty transcript
                            if self.transcript.trimmingCharacters(in: .whitespaces).isEmpty {
                                self.errorMessage = "Dwellable didn't catch that. Feel free to speak again."
                                completion(nil)
                            } else {
                                completion(self.transcript)
                            }
                        }
                    }

                    if let error = error {
                        self.isTranscribing = false
                        self.transcriptionTimeoutTimer?.invalidate()
                        self.transcriptionTimeoutTimer = nil
                        self.handleTranscriptionError(error)
                        completion(nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Speech recognition isn't available right now. Check your device settings."
                self.isTranscribing = false
                self.transcriptionTimeoutTimer?.invalidate()
                self.transcriptionTimeoutTimer = nil
                completion(nil)
            }
        }
    }

    private func handleTranscriptionError(_ error: Error) {
        let nsError = error as NSError

        // Map error codes to user-friendly, brand-appropriate messages
        switch nsError.code {
        case 216:
            // SFSpeechRecognitionError.noMatch - No speech detected
            errorMessage = "Dwellable didn't catch that. Feel free to speak again."
        case 1101:
            // Network/connectivity error
            errorMessage = "Network connection lost. Please check your connection and try again."
        case -1:
            // Timeout or operation cancelled
            errorMessage = "That took a moment. Try again with a shorter recording."
        default:
            // Check domain for permission-related errors
            if nsError.domain == "kLSRightsError" || error.localizedDescription.lowercased().contains("permission") {
                errorMessage = "Speech recognition is disabled. Enable it in Settings to continue."
            } else if error.localizedDescription.lowercased().contains("network") {
                errorMessage = "Can't reach the server. Check your connection and try again."
            } else if error.localizedDescription.lowercased().contains("timeout") {
                errorMessage = "That took a moment. Try again with a shorter recording."
            } else {
                errorMessage = "Dwellable didn't catch your capture. Feel free to articulate again or speak it once more."
            }
        }
    }

    func cancelTranscription() {
        transcriptionTimeoutTimer?.invalidate()
        transcriptionTimeoutTimer = nil
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()
        isTranscribing = false
        transcript = ""
        errorMessage = nil
    }
}
