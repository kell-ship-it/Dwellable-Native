# Dwellable Tools

Development and debugging tools for the Dwellable app.

## Analytics Dashboard

### About
The `analytics-dashboard.html` is a real-time analytics viewer that connects directly to the Supabase backend to display:
- Total moments (voice + text)
- Voice moments count
- Text moments count
- App sessions count
- Recent events (last 500 events)

Useful for quick debugging during development without reopening the app.

### Why It Requires an HTTP Server

The analytics dashboard makes API calls to Supabase using the JavaScript Supabase client library. **Browser security policies prevent cross-origin requests from `file://` URLs**, so the dashboard must be served over HTTP.

**What broke it during security hardening:**
- If the dashboard was previously opened as `file:///Users/kell/Desktop/...` directly in the browser, it worked in older Safari/Chrome versions
- Modern browsers (2024+) enforce strict CORS policies even for `file://` origins
- Opening as `file://` URL → Browser treats it as unique origin → Cannot access `https://lhcjobrtmbawlhjyodxz.supabase.co` → Dashboard shows "Disconnected"

**The fix:**
- Always serve the dashboard via HTTP (localhost) instead of opening the file directly

### How to Use

**Start the server:**
```bash
cd /Users/kell/Desktop/Dwellable-Native/Dwellable/tools
chmod +x SERVE.sh
./SERVE.sh
```

**Access the dashboard:**
- Open your browser to: **http://localhost:8000/analytics-dashboard.html**
- Enter any registered email address (e.g., `pilot2@dwellable.com`)
- Click "Refresh" to load analytics

**Troubleshooting:**
1. **"Port 8000 already in use"** → Change the port in `SERVE.sh` from 8000 to 8001, 8002, etc.
2. **"User not found"** → The email must exist in Supabase `users` table
3. **"No moments or sessions yet"** → Create moments in the app first, then refresh the dashboard
4. **"Disconnected" error** →
   - Make sure you're accessing via `http://localhost:8000/...`, NOT `file:///Users/kell/...`
   - Check browser console (Cmd+Option+J on macOS) for CORS or network errors
   - Ensure you have internet connection (dashboard queries Supabase cloud)

### Credentials in Dashboard

⚠️ **Security Note:** The dashboard contains a Supabase publishable key in plain JavaScript:
```javascript
const SUPABASE_KEY = "sb_publishable_Mlu-MF7FXHHb-S1Kb89lZA_zzZ5dltg";
```

This is intentional:
- **Publishable keys are designed to be public** (unlike secret API keys)
- They can only perform operations allowed by RLS (Row Level Security) policies
- A user can only see their own moments/events due to RLS constraints

### For Developers

**To add new features to the dashboard:**
1. Run `./SERVE.sh` to start the server
2. Edit `analytics-dashboard.html` in your text editor
3. Refresh `http://localhost:8000/analytics-dashboard.html` to see changes
4. Check browser console (Cmd+Option+J) for JavaScript errors

**Important:** Always test with `http://localhost:...`, never with `file://...`
