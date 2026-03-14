import SwiftUI
import Foundation
import Network

// MARK: - HTML Logging Manager

/// Writes logs to JSON and serves them over HTTP on port 8787.
/// Simulator: also writes directly to the project folder.
/// Device: serve via http://[device-ip]:8787/logs — open dwellable-logs.html and enter that URL.
class HTMLLogManager {
    static let shared = HTMLLogManager()

    private let logQueue = DispatchQueue(label: "com.dwellable.html-logging")
    private var logEntries: [[String: String]] = []
    private var logServer: LogHTTPServer?

    private let jsonPath: URL = {
        #if targetEnvironment(simulator)
        return URL(fileURLWithPath: "/Users/kell/Desktop/Dwellable-Native/Dwellable/dwellable-logs.json")
        #else
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("dwellable-logs.json")
        #endif
    }()

    init() {
        if let data = try? Data(contentsOf: jsonPath),
           let existing = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] {
            logEntries = existing
        }
        logServer = LogHTTPServer(logProvider: { [weak self] in
            guard let self = self else { return Data("[]".utf8) }
            return (try? JSONSerialization.data(withJSONObject: self.logEntries, options: .prettyPrinted))
                ?? Data("[]".utf8)
        })
        logServer?.start()
        print("📋 [LOGS] JSON: \(jsonPath.path)")
        print("📡 [LOGS] HTTP server: port 8787 — open dwellable-logs.html and set server URL")
    }

    func log(_ message: String, level: String = "INFO") {
        logQueue.async {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            self.logEntries.append(["timestamp": timestamp, "level": level, "message": message])
            if self.logEntries.count > 500 {
                self.logEntries.removeFirst(self.logEntries.count - 500)
            }
            if let jsonData = try? JSONSerialization.data(withJSONObject: self.logEntries, options: .prettyPrinted) {
                try? jsonData.write(to: self.jsonPath)
            }
        }
    }
}

// MARK: - Log HTTP Server

/// Serves on port 8787:
///   GET /       → the full log dashboard HTML (open this in browser directly)
///   GET /logs   → raw JSON log entries
/// Opening http://[device-ip]:8787 in a browser gives full real-time dashboard.
class LogHTTPServer {
    private var listener: NWListener?
    private let logProvider: () -> Data
    private let serverQueue = DispatchQueue(label: "com.dwellable.log-server")

    init(logProvider: @escaping () -> Data) {
        self.logProvider = logProvider
    }

    func start() {
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            listener = try NWListener(using: params, on: 8787)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handle(connection)
            }
            listener?.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    print("📡 [LOG_SERVER] Open in browser: http://169.254.94.22:8787")
                case .failed(let error):
                    print("📡 [LOG_SERVER] Failed: \(error)")
                default:
                    break
                }
            }
            listener?.start(queue: serverQueue)
        } catch {
            print("📡 [LOG_SERVER] Could not start: \(error)")
        }
    }

    private func handle(_ connection: NWConnection) {
        connection.start(queue: serverQueue)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] data, _, _, _ in
            guard let self = self, let data = data,
                  let request = String(data: data, encoding: .utf8) else { return }

            let isLogsEndpoint = request.hasPrefix("GET /logs")
            if isLogsEndpoint {
                let body = self.logProvider()
                let header = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nAccess-Control-Allow-Origin: *\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"
                let response = Data(header.utf8) + body
                connection.send(content: response, completion: .contentProcessed { _ in connection.cancel() })
            } else {
                // Serve the full dashboard HTML inline — no file needed
                let html = Self.dashboardHTML
                let body = Data(html.utf8)
                let header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(body.count)\r\nConnection: close\r\n\r\n"
                let response = Data(header.utf8) + body
                connection.send(content: response, completion: .contentProcessed { _ in connection.cancel() })
            }
        }
    }

    // The full dashboard HTML, served from the device itself — no CORS issues.
    private static let dashboardHTML = """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Dwellable Console Logs</title>
      <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'SF Mono', Monaco, 'Courier New', monospace; background: #1e1e1e; color: #d4d4d4; padding: 16px; line-height: 1.5; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px; padding-bottom: 12px; border-bottom: 1px solid #333; }
        .title { font-size: 16px; font-weight: bold; color: #4ec9b0; }
        .controls { display: flex; gap: 8px; align-items: center; }
        button { padding: 6px 12px; background: #007acc; color: white; border: none; border-radius: 3px; cursor: pointer; font-size: 11px; }
        button:hover { background: #005a9e; }
        button.sec { background: #3a3a3a; }
        button.sec:hover { background: #4a4a4a; }
        .status { font-size: 11px; color: #666; margin-bottom: 10px; display: flex; gap: 16px; }
        .dot { color: #4ec9b0; }
        .logs-wrap { border: 1px solid #2a2a2a; background: #181818; border-radius: 3px; }
        .logs { overflow-y: auto; padding: 10px; height: calc(100vh - 100px); }
        .entry { display: flex; gap: 10px; margin-bottom: 2px; font-size: 11px; padding: 2px 4px; border-radius: 2px; }
        .entry:hover { background: rgba(255,255,255,.04); }
        .ts { color: #555; width: 180px; flex-shrink: 0; }
        .lv { width: 68px; flex-shrink: 0; font-weight: 600; text-align: center; padding: 0 4px; border-radius: 2px; }
        .lv-ERROR   { color: #f48771; background: rgba(244,135,113,.15); }
        .lv-WARNING { color: #dcdcaa; background: rgba(220,220,170,.12); }
        .lv-SUCCESS { color: #6a9955; background: rgba(106,153,85,.12); }
        .lv-INFO    { color: #4ec9b0; background: rgba(78,201,176,.12); }
        .msg { flex-grow: 1; word-break: break-word; white-space: pre-wrap; }
        .empty { text-align: center; color: #444; padding: 50px 20px; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="header">
        <div class="title">📱 Dwellable Console Logs</div>
        <div class="controls">
          <span class="dot" id="dot">● live</span>
          <button onclick="load()">↺ Refresh</button>
          <button class="sec" onclick="toggle()" id="pauseBtn">Pause</button>
          <button class="sec" onclick="bottom()">↓ Bottom</button>
        </div>
      </div>
      <div class="status">
        <span>Entries: <strong id="cnt">0</strong></span>
        <span>Updated: <span id="ts">—</span></span>
      </div>
      <div class="logs-wrap"><div class="logs" id="logs">
        <div class="empty">Loading logs...</div>
      </div></div>
      <script>
        let auto = true, prev = 0, atBottom = true;
        document.getElementById('logs').addEventListener('scroll', function() {
          atBottom = (this.scrollHeight - this.scrollTop - this.clientHeight) < 40;
        });
        function bottom() { const el = document.getElementById('logs'); el.scrollTop = el.scrollHeight; atBottom = true; }
        function toggle() {
          auto = !auto;
          document.getElementById('pauseBtn').textContent = auto ? 'Pause' : 'Resume';
          document.getElementById('dot').textContent = auto ? '● live' : '○ paused';
        }
        async function load() {
          try {
            const r = await fetch('/logs');
            const logs = await r.json();
            if (logs.length === prev) return;
            prev = logs.length;
            const el = document.getElementById('logs');
            el.innerHTML = '';
            for (const log of logs) {
              const d = document.createElement('div');
              d.className = 'entry';
              d.innerHTML = '<div class="ts">'+esc(log.timestamp)+'</div><div class="lv lv-'+esc(log.level)+'">'+esc(log.level)+'</div><div class="msg">'+esc(log.message)+'</div>';
              el.appendChild(d);
            }
            if (atBottom) bottom();
            document.getElementById('cnt').textContent = logs.length;
            document.getElementById('ts').textContent = new Date().toLocaleTimeString();
          } catch(e) {}
        }
        function esc(s) { return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
        load();
        setInterval(() => { if (auto) load(); }, 1000);
        document.addEventListener('visibilitychange', () => { if (!document.hidden) load(); });
      </script>
    </body>
    </html>
    """
}

// MARK: - App

@main
struct DwellableApp: App {
    @StateObject private var authManager: AuthManager
    private let apiClient: APIClient
    @StateObject private var syncManager: SyncManager

    init() {
        // Initialize HTML logger first (creates JSON and HTML files)
        _ = HTMLLogManager.shared

        // Auto-detect test environment and use appropriate client
        let resolvedClient: APIClient

        // Check if XCTest is loaded (indicates we're running tests)
        if NSClassFromString("XCTest") != nil {
            // Use MockAPIClient when running XCUI tests
            resolvedClient = MockAPIClient()
        } else {
            // Use real Supabase client in production
            resolvedClient = SupabaseAPIClient()
        }

        self.apiClient = resolvedClient
        _authManager = StateObject(wrappedValue: AuthManager(apiClient: resolvedClient))
        // B-013 Fix: Create SyncManager at app startup with placeholder userId
        // It will be used for all users; userId is passed per-view
        _syncManager = StateObject(wrappedValue: SyncManager(apiClient: resolvedClient, userId: "app-sync"))

        // Redirect stderr to a log file in Documents (after properties initialized)
        setupFileLogging()
    }

    // MARK: - File Logging

    private func setupFileLogging() {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logPath = docDir.appendingPathComponent("dwellable-logs.txt").path

        // Open log file in append mode
        if let logFile = fopen(logPath, "a") {
            // Redirect stderr (where print() writes) to the file
            dup2(fileno(logFile), STDERR_FILENO)
            setvbuf(logFile, nil, _IOLBF, 0)
            print("📋 [LOGS] Writing to: \(logPath)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                // Go straight to app — model download happens on first capture if needed
                AppView(apiClient: apiClient, syncManager: syncManager)
                    .environmentObject(authManager)
                    .task {
                        // Pre-load model silently if already downloaded
                        if UserDefaults.standard.bool(forKey: "whisperModelReady") {
                            await TranscriptionManager.shared.setupWhisperKit()
                        }
                    }
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }

}
