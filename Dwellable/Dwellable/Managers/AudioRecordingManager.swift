import Foundation
import AVFoundation
import Combine

class AudioRecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var audioURL: URL?
    @Published var errorMessage: String?
    @Published var hasPermission: Bool?
    @Published var recordingDuration: TimeInterval = 0

    private var audioRecorder: AVAudioRecorder?
    private let audioSession = AVAudioSession.sharedInstance()
    private var durationTimer: Timer?
    private var recordingStartTime: Date?

    private static let MAX_RECORDING_DURATION: TimeInterval = 600 // 10 minutes

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Audio session setup failed: \(error.localizedDescription)"
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
                if !granted {
                    self.errorMessage = "Microphone permission denied. Enable it in Settings to record moments."
                }
                completion(granted)
            }
        }
    }

    func startRecording() {
        // Check permission status first
        let permission = AVAudioSession.sharedInstance().recordPermission

        if permission == .denied {
            DispatchQueue.main.async {
                self.errorMessage = "Microphone permission denied. Enable it in Settings to record moments."
                self.hasPermission = false
            }
        } else if permission == .undetermined {
            requestMicrophonePermission { granted in
                if granted {
                    self.performStartRecording()
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Microphone permission required to record moments."
                    }
                }
            }
        } else {
            performStartRecording()
        }
    }

    private func performStartRecording() {
        do {
            try audioSession.setActive(true)

            let audioURL = getTempAudioURL()
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()

            DispatchQueue.main.async {
                self.isRecording = true
                self.audioURL = audioURL
                self.errorMessage = nil
                self.recordingStartTime = Date()
                self.recordingDuration = 0
                self.startDurationTimer()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Recording start failed: \(error.localizedDescription)"
                self.isRecording = false
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        durationTimer?.invalidate()
        durationTimer = nil

        DispatchQueue.main.async {
            self.isRecording = false
        }
    }

    private func getTempAudioURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(UUID().uuidString).m4a"
        return tempDir.appendingPathComponent(fileName)
    }

    private func startDurationTimer() {
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)

            DispatchQueue.main.async {
                // Stop recording if max duration reached
                if elapsed >= Self.MAX_RECORDING_DURATION {
                    self.stopRecording()
                    self.errorMessage = "Maximum recording duration (10 minutes) reached."
                } else {
                    self.recordingDuration = elapsed
                }
            }
        }
    }

    func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            DispatchQueue.main.async {
                self.errorMessage = "Recording failed"
                self.isRecording = false
            }
        }
    }
}
