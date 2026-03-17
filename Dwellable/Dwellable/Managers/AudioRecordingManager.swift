import Foundation
import AVFoundation
import Combine
import CallKit

class AudioRecordingManager: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published var isRecording = false
    @Published var audioURL: URL?
    @Published var errorMessage: String?
    @Published var hasPermission: Bool?
    @Published var recordingDuration: TimeInterval = 0
    @Published var isAudioReadyForReview: Bool = false
    @Published var warningMessage: String? // 9-minute warning

    private var audioRecorder: AVAudioRecorder?
    private let audioSession = AVAudioSession.sharedInstance()
    private var durationTimer: Timer?
    private var recordingStartTime: Date?
    private var onAudioReady: (() -> Void)?
    var onRecordingLimitReached: (() -> Void)? // Set by CaptureView; fired when 10-min auto-stop completes
    private var hasShownWarning = false // Track if we've already shown the 9-minute warning
    private let callObserver = CXCallObserver()

    private static let MAX_RECORDING_DURATION: TimeInterval = 600 // 10 minutes
    private static let WARNING_THRESHOLD: TimeInterval = 540 // 9 minutes (600 - 60)

    override init() {
        super.init()
        setupAudioSession()
        setupInterruptionObserver()
    }

    private func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    @objc private func handleAudioInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }

        if type == .began && isRecording {
            // Another app or call has taken the microphone — stop and save what we have
            print("⚠️ [INTERRUPTION] Audio session interrupted during recording — stopping")
            onAudioReady = onRecordingLimitReached
            audioRecorder?.stop()
            durationTimer?.invalidate()
            durationTimer = nil
            DispatchQueue.main.async {
                self.isRecording = false
                self.errorMessage = "Recording stopped — your microphone was taken by a call or another app."
            }
        }
    }

    private func isOnActiveCall() -> Bool {
        return callObserver.calls.contains { !$0.hasEnded }
    }

    private func setupAudioSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.audioSession.setCategory(.record, mode: .default, options: [])
                try self.audioSession.setActive(true)
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Audio setup encountered an issue. Try again in a moment."
                }
            }
        }
    }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
                if !granted {
                    self.errorMessage = "Enable microphone access in Settings to capture moments."
                }
                completion(granted)
            }
        }
    }

    func startRecording() {
        // Check for active phone call or FaceTime first
        if isOnActiveCall() {
            DispatchQueue.main.async {
                self.errorMessage = "You're on a call. Finish your call and try again."
            }
            return
        }

        // Check if audio input is available (e.g., no mic hardware detected)
        if !audioSession.isInputAvailable {
            DispatchQueue.main.async {
                self.errorMessage = "Microphone isn't available right now. Try again in a moment."
            }
            return
        }

        // Check permission status
        let permission = AVAudioSession.sharedInstance().recordPermission

        if permission == .denied {
            DispatchQueue.main.async {
                self.errorMessage = "Microphone access is disabled. Enable it in Settings to capture moments."
                self.hasPermission = false
            }
        } else if permission == .undetermined {
            requestMicrophonePermission { granted in
                if granted {
                    self.performStartRecording()
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Enable microphone access in Settings to capture moments."
                    }
                }
            }
        } else {
            performStartRecording()
        }
    }

    private func performStartRecording() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.performStartRecordingOnBackground()
        }
    }

    private func performStartRecordingOnBackground() {
        do {
            // Reset recorder before starting new recording
            audioRecorder = nil

            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let audioURL = getTempAudioURL()
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self

            guard audioRecorder?.record() == true else {
                DispatchQueue.main.async {
                    self.errorMessage = "Recording failed to start. Check microphone access in Settings."
                    self.isRecording = false
                }
                return
            }

            DispatchQueue.main.async {
                self.isRecording = true
                self.audioURL = audioURL
                self.errorMessage = nil
                self.warningMessage = nil
                self.recordingStartTime = Date()
                self.recordingDuration = 0
                self.hasShownWarning = false
                self.startDurationTimer()
            }
        } catch {
            let description = error.localizedDescription.lowercased()
            print("🔴 Recording error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                if description.contains("interrupted") || description.contains("session") {
                    self.errorMessage = "Microphone is in use by another app. Close it and try again."
                } else {
                    self.errorMessage = "Couldn't start recording. Check microphone permissions in Settings."
                }
                self.isRecording = false
            }
        }
    }

    func stopRecording(onReady: @escaping () -> Void) {
        onAudioReady = onReady
        audioRecorder?.stop()
        durationTimer?.invalidate()
        durationTimer = nil

        DispatchQueue.main.async {
            self.isRecording = false
        }
    }

    // Legacy method for backward compatibility
    func stopRecording() {
        stopRecording(onReady: {})
    }

    private func getTempAudioURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "recording_\(UUID().uuidString).m4a"
        return tempDir.appendingPathComponent(fileName)
    }

    private func startDurationTimer() {
        hasShownWarning = false
        durationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.recordingStartTime else { return }
            let elapsed = Date().timeIntervalSince(startTime)

            DispatchQueue.main.async {
                // Show warning at 9 minutes
                if elapsed >= Self.WARNING_THRESHOLD && !self.hasShownWarning {
                    self.hasShownWarning = true
                    self.warningMessage = "Hey, 60 seconds left in recording. Feel free to add another moment to supplement this."
                    print("⏱️ [WARNING] Recording approaching 10-minute limit")
                }

                // Stop recording if max duration reached
                if elapsed >= Self.MAX_RECORDING_DURATION {
                    self.onAudioReady = self.onRecordingLimitReached
                    self.audioRecorder?.stop()
                    self.durationTimer?.invalidate()
                    self.durationTimer = nil
                    self.isRecording = false
                    self.errorMessage = "You've reached the 10-minute capture limit. Start a new moment to continue."
                    print("⏱️ [LIMIT] Recording stopped at 10-minute limit")
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
                self.errorMessage = "Recording encountered an issue. Try again."
                self.isRecording = false
            }
        } else {
            // Signal that audio file has been fully written to disk
            DispatchQueue.main.async {
                self.isAudioReadyForReview = true
                self.onAudioReady?()
            }
        }
    }
}
