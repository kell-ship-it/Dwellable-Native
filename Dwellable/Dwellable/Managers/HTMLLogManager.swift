import Foundation

/// Manages HTML-formatted logging for persistent, viewable console output.
/// Writes logs to both a text file and a JSON file that can be viewed in an HTML dashboard.
class HTMLLogManager {
    static let shared = HTMLLogManager()

    private let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    private let logQueue = DispatchQueue(label: "com.dwellable.html-logging")
    private var logEntries: [[String: String]] = []

    init() {
        setupHTMLFile()
    }

    /// Set up the HTML dashboard file in the Documents directory.
    private func setupHTMLFile() {
        let htmlPath = docDir.appendingPathComponent("dwellable-logs.html")

        let htmlContent = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Dwellable Console Logs</title>
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body {
                    font-family: 'SF Mono', Monaco, 'Courier New', monospace;
                    background: #1e1e1e;
                    color: #d4d4d4;
                    padding: 20px;
                    line-height: 1.5;
                }
                .header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: 20px;
                    padding-bottom: 15px;
                    border-bottom: 1px solid #444;
                }
                .title {
                    font-size: 18px;
                    font-weight: bold;
                    color: #4ec9b0;
                }
                .controls {
                    display: flex;
                    gap: 10px;
                }
                button {
                    padding: 8px 16px;
                    background: #007acc;
                    color: white;
                    border: none;
                    border-radius: 4px;
                    cursor: pointer;
                    font-family: inherit;
                    font-size: 13px;
                }
                button:hover {
                    background: #005a9e;
                }
                button.secondary {
                    background: #6c757d;
                }
                button.secondary:hover {
                    background: #5a6268;
                }
                .status {
                    display: flex;
                    gap: 20px;
                    align-items: center;
                    font-size: 12px;
                    color: #858585;
                }
                .status-item {
                    display: flex;
                    gap: 5px;
                    align-items: center;
                }
                .logs-container {
                    border: 1px solid #444;
                    background: #252526;
                    border-radius: 4px;
                    overflow: hidden;
                    max-height: calc(100vh - 150px);
                    display: flex;
                    flex-direction: column;
                }
                .logs {
                    flex: 1;
                    overflow-y: auto;
                    padding: 15px;
                }
                .log-entry {
                    display: flex;
                    gap: 12px;
                    margin-bottom: 4px;
                    font-size: 12px;
                    padding: 2px 4px;
                    border-radius: 2px;
                }
                .log-entry:hover {
                    background: rgba(255,255,255, 0.05);
                }
                .timestamp {
                    color: #858585;
                    min-width: 190px;
                    flex-shrink: 0;
                }
                .level {
                    min-width: 70px;
                    flex-shrink: 0;
                    font-weight: 600;
                    padding: 0 6px;
                    border-radius: 2px;
                    text-align: center;
                }
                .level-ERROR {
                    color: #ffffff;
                    background: rgba(244, 135, 113, 0.3);
                    color: #f48771;
                }
                .level-WARNING {
                    color: #dcdcaa;
                    background: rgba(220, 220, 170, 0.15);
                }
                .level-SUCCESS {
                    color: #6a9955;
                    background: rgba(106, 153, 85, 0.15);
                }
                .level-INFO {
                    color: #4ec9b0;
                    background: rgba(78, 201, 176, 0.15);
                }
                .message {
                    flex-grow: 1;
                    word-break: break-word;
                    white-space: pre-wrap;
                    color: #d4d4d4;
                }
                .empty {
                    text-align: center;
                    color: #858585;
                    padding: 40px 20px;
                }
                .footer {
                    border-top: 1px solid #444;
                    padding-top: 10px;
                    margin-top: 10px;
                    font-size: 11px;
                    color: #858585;
                }
                @media (max-width: 768px) {
                    body { padding: 10px; }
                    .header { flex-direction: column; align-items: flex-start; gap: 10px; }
                    .controls { width: 100%; }
                    .log-entry { flex-direction: column; gap: 4px; }
                    .timestamp { min-width: auto; }
                    .level { min-width: auto; }
                }
            </style>
        </head>
        <body>
            <div class="header">
                <div class="title">📱 Dwellable Console Logs</div>
                <div class="controls">
                    <button onclick="loadLogs()">🔄 Refresh</button>
                    <button class="secondary" onclick="toggleAutoRefresh()" id="autoBtn">⏱ Auto: ON</button>
                    <button class="secondary" onclick="clearLogs()">🗑 Clear</button>
                </div>
            </div>

            <div class="status">
                <div class="status-item">
                    <span>📊 Entries:</span>
                    <span id="entryCount">0</span>
                </div>
                <div class="status-item">
                    <span>⏱ Last Update:</span>
                    <span id="lastUpdate">Never</span>
                </div>
                <div class="status-item" id="filePathInfo" style="font-size: 11px; color: #6a9955;">
                    📂 Logs updated in real-time
                </div>
            </div>

            <div class="logs-container">
                <div class="logs" id="logs">
                    <div class="empty">Loading logs...</div>
                </div>
            </div>

            <div class="footer">
                💡 Tip: Refresh auto-updates every 1 second. Logs persist across app restarts. To clear, tap the app's Settings and select "Clear Debug Logs".
            </div>

            <script>
                let autoRefresh = true;
                let lastEntryCount = 0;

                async function loadLogs() {
                    try {
                        const response = await fetch('dwellable-logs.json');
                        if (!response.ok) throw new Error('Logs file not found');

                        const logs = await response.json();
                        const logsDiv = document.getElementById('logs');

                        if (logs.length === 0) {
                            logsDiv.innerHTML = '<div class="empty">No logs yet. Start using the app to see logs here.</div>';
                            document.getElementById('entryCount').textContent = '0';
                            return;
                        }

                        logsDiv.innerHTML = '';

                        logs.forEach((log, index) => {
                            const entry = document.createElement('div');
                            entry.className = 'log-entry';
                            entry.innerHTML = `
                                <div class="timestamp">${log.timestamp}</div>
                                <div class="level level-${log.level}">${log.level}</div>
                                <div class="message">${escapeHtml(log.message)}</div>
                            `;
                            logsDiv.appendChild(entry);
                        });

                        logsDiv.scrollTop = logsDiv.scrollHeight;
                        document.getElementById('entryCount').textContent = logs.length;
                        document.getElementById('lastUpdate').textContent = new Date().toLocaleTimeString();

                        if (logs.length !== lastEntryCount) {
                            lastEntryCount = logs.length;
                        }
                    } catch (err) {
                        document.getElementById('logs').innerHTML = `
                            <div class="empty" style="color: #f48771;">
                                ⚠️ Error loading logs: ${escapeHtml(err.message)}<br>
                                <small style="color: #858585; margin-top: 10px; display: block;">
                                    Make sure the app is running and has written at least one log entry.
                                </small>
                            </div>
                        `;
                    }
                }

                function escapeHtml(text) {
                    const map = {
                        '&': '&amp;',
                        '<': '&lt;',
                        '>': '&gt;',
                        '"': '&quot;',
                        "'": '&#039;'
                    };
                    return String(text).replace(/[&<>"']/g, m => map[m]);
                }

                function toggleAutoRefresh() {
                    autoRefresh = !autoRefresh;
                    const btn = document.getElementById('autoBtn');
                    btn.textContent = `⏱ Auto: ${autoRefresh ? 'ON' : 'OFF'}`;
                }

                function clearLogs() {
                    if (confirm('Clear all logs? This cannot be undone.')) {
                        alert('To clear logs, open the app → Settings → Debug → Clear Logs');
                    }
                }

                // Load logs on page load
                loadLogs();

                // Auto-refresh every 1 second if enabled
                setInterval(() => {
                    if (autoRefresh) loadLogs();
                }, 1000);

                // Reload when page becomes visible (tab focus)
                document.addEventListener('visibilitychange', () => {
                    if (!document.hidden && autoRefresh) {
                        loadLogs();
                    }
                });
            </script>
        </body>
        </html>
        """

        do {
            try htmlContent.write(to: htmlPath, atomically: true, encoding: .utf8)
            print("📄 [HTML_LOGS] Dashboard created at: \(htmlPath.path)")
        } catch {
            print("❌ [HTML_LOGS] Failed to create HTML file: \(error.localizedDescription)")
        }
    }

    /// Log a message with timestamp and level, writing to JSON file.
    func log(_ message: String, level: String = "INFO") {
        logQueue.async {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            let entry: [String: String] = [
                "timestamp": timestamp,
                "level": level,
                "message": message
            ]

            self.logEntries.append(entry)

            // Keep last 500 entries to avoid huge file
            if self.logEntries.count > 500 {
                self.logEntries.removeFirst(self.logEntries.count - 500)
            }

            // Write to JSON file
            let jsonPath = self.docDir.appendingPathComponent("dwellable-logs.json")
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: self.logEntries, options: .prettyPrinted)
                try jsonData.write(to: jsonPath, atomically: true)
            } catch {
                print("⚠️ [HTML_LOGS] Failed to write JSON: \(error.localizedDescription)")
            }
        }
    }

    /// Clear all logs.
    func clearAllLogs() {
        logQueue.async {
            self.logEntries.removeAll()
            let jsonPath = self.docDir.appendingPathComponent("dwellable-logs.json")
            try? "[]".write(to: jsonPath, atomically: true, encoding: .utf8)
            print("🗑 [HTML_LOGS] All logs cleared")
        }
    }

    /// Get path to the HTML logs dashboard for reference.
    func getHTMLPath() -> String {
        return docDir.appendingPathComponent("dwellable-logs.html").path
    }

    /// Get path to the JSON logs for reference.
    func getJSONPath() -> String {
        return docDir.appendingPathComponent("dwellable-logs.json").path
    }
}
