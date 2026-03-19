#!/usr/bin/env python3
"""
Export all moments from Supabase to CSV
"""
import json
import csv
import re

result_file = "/Users/kell/.claude/projects/-Users-kell-Projects-dwellable-rn--claude-worktrees-practical-galileo/c267a561-ca5d-4c90-8a86-a744e6a902c4/tool-results/mcp-f50101fb-7bd2-4d63-bef1-5705298fb357-execute_sql-1773873554811.txt"

try:
    with open(result_file, 'r') as f:
        content = f.read()
        data = json.loads(content)

    # Extract the text field which contains the actual result
    result_text = data[0]['text'] if data else ""

    # Parse the JSON result
    result_json = json.loads(result_text)

    # Extract the untrusted-data content
    match = re.search(r'<untrusted-data[^>]*>\n(.*)\n</untrusted-data', result_json['result'], re.DOTALL)
    if match:
        data_str = match.group(1)
        moments = json.loads(data_str)

        print(f"Found {len(moments)} moments to export")

        # Write to CSV
        csv_file = "/Users/kell/Desktop/Dwellable-Native/Dwellable/moments_export.csv"
        if moments:
            keys = moments[0].keys()
            with open(csv_file, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=keys)
                writer.writeheader()
                writer.writerows(moments)

            print(f"✅ Exported {len(moments)} moments to: {csv_file}")
            print(f"\nFile location: {csv_file}")
        else:
            print("No moments found to export")
    else:
        print("Could not parse untrusted-data section")

except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
