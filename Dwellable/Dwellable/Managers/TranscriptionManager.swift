import Foundation
import Speech
import Combine

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

    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    break
                case .denied, .restricted:
                    self.errorMessage = "Speech recognition permission denied. Enable it in Settings."
                case .notDetermined:
                    break
                @unknown default:
                    self.errorMessage = "Unknown speech recognition permission status."
                }
            }
        }
    }

    func transcribeAudio(from fileURL: URL, completion: @escaping (String?) -> Void) {
        isTranscribing = true
        errorMessage = nil
        transcript = ""

        // Set up timeout safety net
        transcriptionTimeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.TRANSCRIPTION_TIMEOUT, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                if self?.isTranscribing == true {
                    self?.errorMessage = "Transcription took too long. Please try again with a shorter recording."
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
                self.errorMessage = "Audio session setup failed: \(error.localizedDescription)"
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
                                self.errorMessage = "No speech was detected. Please try re-recording."
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
                self.errorMessage = "Speech recognition is not available on this device."
                self.isTranscribing = false
                self.transcriptionTimeoutTimer?.invalidate()
                self.transcriptionTimeoutTimer = nil
                completion(nil)
            }
        }
    }

    private func handleTranscriptionError(_ error: Error) {
        let nsError = error as NSError

        // Map error codes to user-friendly messages
        switch nsError.code {
        case 216:
            // SFSpeechRecognitionError.noMatch - No speech detected
            errorMessage = "No speech detected. Please speak clearly and try again."
        case 1101:
            // Network/connectivity error
            errorMessage = "Network error. Please check your connection and try again."
        case -1:
            // Timeout or operation cancelled
            errorMessage = "Transcription took too long. Please try a shorter recording."
        default:
            // Check domain for permission-related errors
            if nsError.domain == "kLSRightsError" || error.localizedDescription.lowercased().contains("permission") {
                errorMessage = "Speech recognition permission was denied. Please enable it in Settings."
            } else if error.localizedDescription.lowercased().contains("network") {
                errorMessage = "Network connection error. Please try again."
            } else if error.localizedDescription.lowercased().contains("timeout") {
                errorMessage = "Transcription took too long. Please try a shorter recording."
            } else {
                errorMessage = "Transcription failed. Please try again."
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
