#!/bin/bash

# Dwellable Analytics Dashboard Server
# Starts a local HTTP server for development/debugging
# The analytics dashboard REQUIRES HTTP (not file://) to work with Supabase

echo "🚀 Starting Dwellable Analytics Server..."
echo ""
echo "📍 Server will run at: http://localhost:8000"
echo "📊 Analytics Dashboard: http://localhost:8000/analytics-dashboard.html"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

cd "$(dirname "$0")" || exit 1

# Use Python 3 (cross-platform, pre-installed on macOS)
python3 -m http.server 8000

# Alternative: If Python 3 not available, try Node.js
# npx http-server -p 8000
