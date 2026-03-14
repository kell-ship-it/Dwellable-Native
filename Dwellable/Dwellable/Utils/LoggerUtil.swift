import Foundation

/// Global logging utility that writes to both console and HTML dashboard.
/// Use this instead of print() for important messages you want to see in the logs dashboard.
///
/// Example:
/// ```
/// logMessage("User authenticated successfully", level: "SUCCESS")
/// logMessage("Network error occurred", level: "ERROR")
/// logMessage("App backgrounded", level: "WARNING")
/// ```
func logMessage(_ message: String, level: String = "INFO") {
    let timestamp = ISO8601DateFormatter().string(from: Date())
    let prefix = prefixForLevel(level)
    let logLine = "\(prefix) [\(level.uppercased())] \(message)"

    // Print to console (goes to stderr, captured by file logging)
    print(logLine)

    // Also log to HTML dashboard
    HTMLLogManager.shared.log(message, level: level.uppercased())
}

/// Error-specific logging (red in dashboard)
func logError(_ message: String) {
    logMessage(message, level: "ERROR")
}

/// Warning logging (yellow in dashboard)
func logWarning(_ message: String) {
    logMessage(message, level: "WARNING")
}

/// Success logging (green in dashboard)
func logSuccess(_ message: String) {
    logMessage(message, level: "SUCCESS")
}

/// Info logging (cyan in dashboard)
func logInfo(_ message: String) {
    logMessage(message, level: "INFO")
}

// MARK: - Private

private func prefixForLevel(_ level: String) -> String {
    let upper = level.uppercased()
    switch upper {
    case "ERROR": return "❌"
    case "WARNING": return "⚠️"
    case "SUCCESS": return "✅"
    case "INFO": return "ℹ️"
    default: return "•"
    }
}
