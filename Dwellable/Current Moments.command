#!/bin/bash
# Double-click this file to refresh the Dwellable dashboard cache
# It queries Supabase fresh and updates dashboard-data.json

cd "$(dirname "$0")"

echo "🔄 Refreshing Dwellable Dashboard..."
echo ""

if ! command -v node &> /dev/null; then
  echo "❌ Node.js is not installed or not in PATH"
  echo "Install Node.js from https://nodejs.org/ and try again"
  read -p "Press Enter to exit..."
  exit 1
fi

if [ ! -f "package.json" ]; then
  echo "❌ package.json not found in $(pwd)"
  echo "Make sure you're in the Dwellable dashboard directory"
  read -p "Press Enter to exit..."
  exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
  echo ""
fi

# Run the refresh script
npm run refresh

# Keep the window open so you can see the results
read -p "Press Enter to close this window..."
