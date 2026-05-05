# Console Logs Dashboard

## Overview

Dwellable now includes a persistent console logs dashboard that captures all important log events even when Xcode's console disappears or gets disconnected.

**Status:** ✅ Enabled by default on app launch

---

## Viewing Logs

### Option 1: On the Simulator (Recommended for Development)

1. **Build and run the app** in the iOS Simulator
2. **Open Safari** on the Mac
3. Navigate to: `file:///Users/kell/Desktop/Dwellable-Native/Dwellable/Documents/dwellable-logs.html`
4. **Logs auto-refresh every 1 second** — you'll see real-time updates as the app runs

**Or:**
1. Open **Finder** → **Documents** folder
2. Find `dwellable-logs.html`
3. Double-click to open in Safari

### Option 2: On Device (Physical iPhone/iPad)

> Requires Xcode setup for local file serving. For now, use the simulator approach.

---

## Log Levels & Colors

The dashboard uses color-coded log levels for easy scanning:

| Level | Color | Emoji | Use Case |
|-------|-------|-------|----------|
| **ERROR** | 🔴 Red | ❌ | Critical failures, crashes, network errors |
| **WARNING** | 🟡 Yellow | ⚠️ | Performance issues, edge cases, timeouts |
| **SUCCESS** | 🟢 Green | ✅ | Successful operations, completed tasks |
| **INFO** | 🔵 Cyan | ℹ️ | General information, state changes |

---

## Using LoggerUtil in Code

Instead of `print()`, use the logging utility:

```swift
import Foundation

// Info logging
logInfo("User tapped record button")

// Success logging
logSuccess("Audio file saved successfully")

// Warning logging
logWarning("Recording approaching 10-minute limit")

// Error logging
logError("Failed to initialize WhisperKit: \(error.localizedDescription)")

// Or with explicit level
logMessage("Custom event occurred", level: "INFO")
```

### Examples in Codebase

**TranscriptionManager.swift:**
```swift
logSuccess("WhisperKit initialized successfully")
logError("Transcription failed: \(error)")
logInfo("Starting transcription...")
```

**AudioRecordingManager.swift:**
```swift
logWarning("Recording approaching 10-minute limit")
logMessage("Recording auto-stopped at 10 minutes", level: "WARNING")
```

---

## Dashboard Features

### Real-Time Auto-Refresh
- **Default:** Auto-refreshes every 1 second
- **Toggle:** Click "⏱ Auto: ON" to pause/resume

### Manual Refresh
- Click "🔄 Refresh" button to manually reload logs
- Useful if auto-refresh is disabled

### Entry Counter
- Shows total number of log entries
- Last 500 entries are kept (oldest entries rotated out)

### Last Update Timestamp
- Shows when logs were last loaded
- Updates continuously if auto-refresh is enabled

### Mobile-Friendly
- Dashboard is responsive and works on iPad/iPhone screen sizes
- Optimized for landscape orientation on device

---

## Log Files

### 1. HTML Dashboard
- **Path:** `~/Documents/dwellable-logs.html`
- **Auto-generated:** On app first launch
- **Contains:** Pretty-formatted, color-coded logs with real-time updates
- **Refreshes:** Every 1 second automatically

### 2. JSON Data File
- **Path:** `~/Documents/dwellable-logs.json`
- **Auto-generated:** When first log is written
- **Format:** JSON array of log entries with timestamp, level, message
- **Updated:** In real-time as logs are written
- **Max Entries:** 500 (older entries automatically removed)

### 3. Text Log File (Legacy)
- **Path:** `~/Documents/dwellable-logs.txt`
- **Format:** Plain text, one entry per line
- **Use:** Fallback view if HTML dashboard isn't needed

---

## Troubleshooting

### Logs Not Appearing?

1. **Make sure app is running** — logs only appear when the app writes events
2. **Refresh the dashboard** — click "🔄 Refresh" or disable/enable auto-refresh
3. **Check file paths** — the HTML file should be at the path shown in Safari
4. **App permissions** — ensure app has permission to write to Documents

### Dashboard Shows "Loading logs..." indefinitely?

- The `dwellable-logs.json` file may not exist yet
- **Fix:** Generate a log by using the app (e.g., attempt to record audio)
- Once the app writes at least one log, the dashboard will populate

### Want to Clear All Logs?

From the app (requires developer mode setup):
1. Settings → Debug → Clear Logs *(requires implementation)*

Or manually:
1. Delete `dwellable-logs.json` from Documents folder
2. Dashboard will show "No logs yet" until app generates new entries
3. Restart app to resume logging

---

## Technical Details

### How It Works

1. **Log Entry Created** → Code calls `logMessage()` or specific log function
2. **Console Output** → Message printed to console (captured by Xcode)
3. **JSON File Update** → Simultaneously written to `dwellable-logs.json`
4. **HTML Refresh** → Dashboard fetches JSON every 1 second and renders logs
5. **Visual Display** → Color-coded, formatted entries shown in Safari

### File Locations (Mac Terminal)

```bash
# View HTML dashboard
cat ~/Documents/dwellable-logs.html

# View JSON logs
cat ~/Documents/dwellable-logs.json

# View text logs
tail -f ~/Documents/dwellable-logs.txt

# Delete logs
rm ~/Documents/dwellable-logs.json
```

### Storage Limits

- **Max entries kept:** 500 (prevents huge files)
- **File size:** ~50-100 KB for JSON (with 500 entries)
- **Performance:** Auto-cleanup when exceeding limits

---

## Testing Checklist

Before deploying, verify logs work end-to-end:

- [ ] Start app → see "Writing to Documents/dwellable-logs.txt" in Xcode console
- [ ] App generates an event (e.g., press record button)
- [ ] Open `dwellable-logs.html` in Safari → see logs with timestamps
- [ ] Logs auto-refresh → disable auto-refresh, then re-enable
- [ ] Colors are correct → ERROR=red, WARNING=yellow, SUCCESS=green, INFO=cyan
- [ ] Complete a full transcription → verify all transcription logs appear
- [ ] Check file cleanup → verify temp audio files are deleted (check logs)

---

## Next Steps (Future)

Planned enhancements:

- [ ] Log filtering by level (show only errors, etc.)
- [ ] Log search functionality (find text in logs)
- [ ] Export logs to file
- [ ] DebugView in-app for quick access
- [ ] Settings panel for log retention configuration
- [ ] Network request logging (optional)

---

## FAQ

**Q: Will logs slow down the app?**
A: No. Logging is queued asynchronously and doesn't block the main thread.

**Q: How much disk space do logs use?**
A: Typically 50-100 KB with 500 entries. Old entries are automatically removed.

**Q: Can I use this in production/TestFlight?**
A: Yes, but you'll probably want to disable auto-logging in release builds. See `HTMLLogManager.swift` for conditional compilation options.

**Q: Do logs persist after app restart?**
A: Yes. JSON file is saved to Documents and survives app termination.

**Q: Can I view logs on a physical device?**
A: Yes, if you set up local file sharing or a debug web server (advanced setup required).

---

## Architecture Reference

- **Logging Manager:** `Dwellable/Managers/HTMLLogManager.swift`
- **Logging Utility:** `Dwellable/Utils/LoggerUtil.swift`
- **Dashboard:** Auto-generated as `~/Documents/dwellable-logs.html`
- **Data:** Stored as `~/Documents/dwellable-logs.json`

---

**Ready to use!** Start the app, open the HTML dashboard, and watch logs appear in real-time.
