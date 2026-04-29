#!/usr/bin/env python3
import json
import subprocess
import sys

SUPABASE_URL = 'https://lhcjobrtmbawlhjyodxz.supabase.co'
SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA'

try:
    # Fetch data using curl
    cmd = [
        'curl', '-s', '-X', 'GET',
        '-H', f'Authorization: Bearer {SUPABASE_SERVICE_KEY}',
        '-H', 'Content-Type: application/json',
        '-H', 'Prefer: return=representation',
        f'{SUPABASE_URL}/rest/v1/users?select=id,email,moments(id,created_at)'
    ]

    result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)

    if result.returncode != 0:
        print(json.dumps({'error': f'curl failed: {result.stderr}'}))
        sys.exit(1)

    users = json.loads(result.stdout)

    # Aggregate data
    result_data = []
    for user in users:
        moments = user.get('moments', [])
        first_moment = None
        last_moment = None

        if moments:
            sorted_moments = sorted(moments, key=lambda m: m['created_at'])
            first_moment = sorted_moments[0]['created_at']
            last_moment = sorted_moments[-1]['created_at']

        result_data.append({
            'id': user['id'],
            'email': user['email'],
            'moment_count': len(moments),
            'first_moment_created': first_moment,
            'last_moment_created': last_moment
        })

    # Sort by moment count
    result_data.sort(key=lambda x: x['moment_count'], reverse=True)

    print(json.dumps(result_data))

except Exception as e:
    print(json.dumps({'error': str(e)}))
    sys.exit(1)
