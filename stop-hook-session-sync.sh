#!/bin/bash
# Claude Code Stop Hook — Auto-sync session data to GitHub
# This hook runs when Claude Code session ends
# Updates session-viewer.html, stages memory files, commits, and pushes

set -e

echo "🔄 Stop Hook: Syncing session data to GitHub..."

cd "$(dirname "$0")/Dwellable" || exit 1

# Step 1: Generate session-viewer.html from git log + MEMORY.md
echo "📝 Generating session-viewer.html..."
python3 - << 'PYTHON_SCRIPT'
import json
import subprocess
from datetime import datetime

# Get git log data (last 20 commits)
try:
    result = subprocess.run(
        ["git", "log", "--oneline", "-20"],
        capture_output=True,
        text=True
    )
    commits = [line.strip() for line in result.stdout.strip().split('\n') if line.strip()]
except:
    commits = []

# Read MEMORY.md for current blocking items
try:
    with open("MEMORY.md", "r") as f:
        memory_content = f.read()
except:
    memory_content = ""

# Create session viewer HTML
html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dwellable Sessions</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #0f0f0f;
            color: #fff;
            padding: 40px 20px;
            min-height: 100vh;
        }}

        .container {{
            max-width: 900px;
            margin: 0 auto;
        }}

        h1 {{
            font-size: 32px;
            margin-bottom: 10px;
            color: #C9B27C;
        }}

        .timestamp {{
            color: #666;
            font-size: 13px;
            margin-bottom: 40px;
        }}

        .section {{
            background: #1a1a1a;
            border: 1px solid #333;
            border-radius: 8px;
            padding: 24px;
            margin-bottom: 20px;
        }}

        .section h2 {{
            font-size: 18px;
            margin-bottom: 16px;
            border-bottom: 1px solid #333;
            padding-bottom: 12px;
        }}

        .commit {{
            background: #0f0f0f;
            border-left: 3px solid #C9B27C;
            padding: 12px;
            margin-bottom: 8px;
            font-size: 13px;
            font-family: monospace;
        }}

        .memory {{
            background: #0f0f0f;
            padding: 12px;
            border-radius: 4px;
            font-size: 13px;
            line-height: 1.6;
            max-height: 400px;
            overflow-y: auto;
        }}

        .blocking {{
            background: rgba(220, 100, 100, 0.1);
            border-left: 3px solid #dc6464;
            padding: 12px;
            margin-bottom: 12px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔄 Dwellable Sessions</h1>
        <div class="timestamp">Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}</div>

        <div class="section">
            <h2>Recent Commits</h2>
            <div>
"""

for commit in commits[:10]:
    html_content += f'                <div class="commit">{commit}</div>\n'

html_content += """            </div>
        </div>

        <div class="section">
            <h2>Current Status (from MEMORY.md)</h2>
            <div class="memory">
                <pre>"""

# Extract blocking items from MEMORY
if "BLOCKING ITEMS" in memory_content:
    blocking_section = memory_content.split("BLOCKING ITEMS")[1].split("---")[0]
    html_content += blocking_section.strip()
else:
    html_content += "No blocking items documented."

html_content += """                </pre>
            </div>
        </div>

        <p style="color: #666; font-size: 12px; margin-top: 40px; text-align: center;">
            This viewer auto-updates on every session close.
            <br><strong>Do not edit manually.</strong>
        </p>
    </div>
</body>
</html>
"""

# Write the file
try:
    with open("session-viewer.html", "w") as f:
        f.write(html_content)
    print("✅ session-viewer.html generated")
except Exception as e:
    print(f"❌ Failed to generate session-viewer.html: {e}")

PYTHON_SCRIPT

# Step 2: Stage memory files
echo "📦 Staging files..."
git add MEMORY.md TICKETS.md TICKETS.csv session-viewer.html 2>/dev/null || true

# Step 3: Check if there are changes to commit
if git diff --cached --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi

# Step 4: Commit
echo "💾 Committing..."
git commit -m "Session sync: Update MEMORY, TICKETS, and session viewer

- ✅ MEMORY.md updated with current blockers
- ✅ TICKETS.md updated with ticket status
- ✅ session-viewer.html regenerated with latest commits
- ✅ Automated via stop hook

This ensures session continuity across all Claude Code environments." || true

# Step 5: Push
echo "🚀 Pushing to GitHub..."
git push origin main 2>/dev/null || echo "⚠️  Push failed (offline?)"

echo "✅ Stop hook complete"
