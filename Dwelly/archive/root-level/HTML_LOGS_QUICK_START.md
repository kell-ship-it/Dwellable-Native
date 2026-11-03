# HTML Logs Dashboard — Quick Start

## View Logs in 3 Steps

### Step 1: Launch the App
```bash
# Build and run in simulator
xcodebuild -scheme Dwelly -configuration Debug -sdk iphonesimulator
# Then run on simulator in Xcode (Cmd + R)
```

### Step 2: Use the App
- Log in
- Record a moment
- Watch it transcribe with WhisperKit

### Step 3: Open the Logs Dashboard
**In Safari (or any browser):**
```
file:///Users/kell/Desktop/Dwelly-Native/Dwelly/Documents/dwelly-logs.html
```

Or **via Terminal:**
```bash
open "file:///Users/kell/Desktop/Dwelly-Native/Dwelly/Documents/dwelly-logs.html"
```

---

## What You'll See

### Real-Time Log Entries
- 🟢 **Green (SUCCESS)** — Operations completed (`✅ Moment saved successfully`)
- 🔴 **Red (ERROR)** — Failures (`❌ JWT refresh failed`)
- 🟡 **Yellow (WARNING)** — Important info (`⏱️ Recording approaching 10-minute limit`)
- 🔵 **Cyan (INFO)** — General info (`ℹ️ Starting transcription...`)

### Auto-Refresh
- Dashboard auto-updates **every 1 second**
- Click "⏱ Auto: OFF" to pause
- Click "🔄 Refresh" to manual update

### Example Log Flow (Moment Save)
```
[2026-03-14T08:30:15.123Z] [INFO] User tapped Save button
[2026-03-14T08:30:15.234Z] [INFO] Creating moment with WhisperKit transcript
[2026-03-14T08:30:16.100Z] [INFO] Calling apiClient.saveMoment()
[2026-03-14T08:30:16.456Z] [SUCCESS] Moment saved successfully
[2026-03-14T08:30:16.789Z] [INFO] Moment saved locally and queued for sync
```

---

## Files Created

| File | Location | Purpose |
|------|----------|---------|
| **dwelly-logs.html** | `~/Documents/dwelly-logs.html` | Dashboard (open in Safari) |
| **dwelly-logs.json** | `~/Documents/dwelly-logs.json` | Actual log data (fetched by dashboard) |
| **dwelly-logs.txt** | `~/Documents/dwelly-logs.txt` | Backup text logs (plain text) |

---

## Troubleshooting

### Dashboard shows "No logs yet"
- Make sure the app is **running**
- Perform an action (login, record, save)
- Refresh the dashboard

### Dashboard shows "Error loading logs"
- Check that file path is correct (copy from above)
- Make sure app has launched at least once
- Try refreshing the page

### Want to see logs in Terminal?
```bash
# Real-time text logs
tail -f ~/Documents/dwelly-logs.txt

# View JSON logs
cat ~/Documents/dwelly-logs.json | jq '.'

# Count log entries
cat ~/Documents/dwelly-logs.json | jq 'length'

# Filter logs by level
cat ~/Documents/dwelly-logs.json | jq '.[] | select(.level=="ERROR")'
```

---

## Key Events to Watch For

### Recording
```
✅ [WHISPERKIT] Model loaded and ready
📊 [TRANSCRIPTION_START] File: recording.m4a, Size: 2.5 MB
🔄 [WHISPERKIT] Starting transcription...
✅ [TRANSCRIPTION_COMPLETE] Length: 247 chars, Elapsed: 12.3s
```

### Saving
```
🔵 API Request: POST https://lhcjobrtmbawlhjyodxz.supabase.co/rest/v1/moments
🟢 Save Response (201):
✅ Moment saved successfully
```

### JWT Refresh (if token expires)
```
⚠️ Save failed, attempting to refresh JWT token...
✅ JWT token refreshed successfully
🔄 Retrying save with refreshed token...
✅ Moment saved successfully
```

---

## Save & Share Logs

If something goes wrong, share the logs:

```bash
# Copy logs to Desktop for sharing
cp ~/Documents/dwelly-logs.json ~/Desktop/
cp ~/Documents/dwelly-logs.txt ~/Desktop/

# Or create a zip
zip ~/Desktop/dwelly-logs.zip ~/Documents/dwelly-logs.*
```

---

**That's it! Your logs are now visible in a persistent HTML dashboard. 🚀**
