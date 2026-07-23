import Foundation

class DiagnosticsManager: ObservableObject {
    static let shared = DiagnosticsManager()

    @Published var logs: [DiagnosticLog] = []
    @Published var isDebugModeEnabled = UserDefaults.standard.bool(forKey: "debug_mode_enabled")

    private let maxLogs = 100

    struct DiagnosticLog {
        let timestamp: Date
        let checkpoint: String
        let message: String
        let level: LogLevel

        enum LogLevel {
            case info, warning, error, success

            var emoji: String {
                switch self {
                case .info: return "ℹ️"
                case .warning: return "⚠️"
                case .error: return "❌"
                case .success: return "✅"
                }
            }
        }

        var formatted: String {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss.SSS"
            let timeStr = timeFormatter.string(from: timestamp)
            return "\(level.emoji) [\(timeStr)] \(checkpoint): \(message)"
        }
    }

    func log(_ checkpoint: String, _ message: String, level: DiagnosticLog.LogLevel = .info) {
        let log = DiagnosticLog(timestamp: Date(), checkpoint: checkpoint, message: message, level: level)

        DispatchQueue.main.async {
            self.logs.append(log)
            if self.logs.count > self.maxLogs {
                self.logs.removeFirst()
            }
        }

        // Also log to console
        print("[\(checkpoint)] \(message)")
    }

    func toggleDebugMode() {
        isDebugModeEnabled.toggle()
        UserDefaults.standard.set(isDebugModeEnabled, forKey: "debug_mode_enabled")
    }

    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }

    // CHECKPOINT: File Written
    func logFileWritten(path: String, size: Int) {
        let sizeKB = Double(size) / 1024.0
        log("FILE_WRITTEN", "Path: \(path)\nSize: \(String(format: "%.1f", sizeKB)) KB", level: .success)
    }

    // CHECKPOINT: Transcription Starting
    func logTranscriptionStart(fileURL: URL, fileSize: Int) {
        let fileManager = FileManager.default
        let exists = fileManager.fileExists(atPath: fileURL.path)
        let sizeKB = Double(fileSize) / 1024.0
        log("TRANSCRIPTION_START",
            "File exists: \(exists)\nSize: \(String(format: "%.1f", sizeKB)) KB\nURL: \(fileURL.lastPathComponent)",
            level: exists ? .success : .warning)
    }

    // CHECKPOINT: Permission Check
    func logPermissionCheck(granted: Bool) {
        log("PERMISSION_CHECK", "Speech recognition: \(granted ? "GRANTED" : "DENIED")", level: granted ? .success : .error)
    }

    // CHECKPOINT: File Validation
    func logFileValidation(passed: Bool, reason: String) {
        log("FILE_VALIDATION", reason, level: passed ? .success : .error)
    }

    // CHECKPOINT: Transcription Task Created
    func logTranscriptionTaskCreated(success: Bool) {
        log("TRANSCRIPTION_TASK", "Task created: \(success ? "YES" : "NO")", level: success ? .success : .error)
    }

    // CHECKPOINT: Partial Results
    func logPartialResult(transcript: String, confidence: Double) {
        log("PARTIAL_RESULT", "Length: \(transcript.count) chars, Confidence: \(Int(confidence * 100))%", level: .info)
    }

    // CHECKPOINT: Transcription Complete
    func logTranscriptionComplete(transcript: String, elapsed: TimeInterval) {
        let length = transcript.trimmingCharacters(in: .whitespaces).count
        let isEmpty = length == 0
        log("TRANSCRIPTION_COMPLETE",
            "Transcript length: \(length) chars\nElapsed: \(String(format: "%.1f", elapsed))s",
            level: isEmpty ? .warning : .success)
    }

    // CHECKPOINT: Transcription Error
    func logTranscriptionError(errorCode: Int, domain: String, description: String) {
        log("TRANSCRIPTION_ERROR",
            "Code: \(errorCode)\nDomain: \(domain)\nMessage: \(description)",
            level: .error)
    }

    // CHECKPOINT: Timeout
    func logTimeout(elapsedSeconds: TimeInterval) {
        log("TIMEOUT", "Transcription took longer than \(elapsedSeconds)s", level: .error)
    }
}
