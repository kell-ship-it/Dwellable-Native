#!/bin/bash

API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxoY2pvYnJ0bWJhd2xoanlvZHh6Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MjkxNDk3OCwiZXhwIjoyMDg4NDkwOTc4fQ.RvLHrQ29m0UwZGXf8ioE8tN0K7j-q1eHjkCqPn6TLbA"

# Count all moments
echo "=== Total moments in Supabase ==="
curl -s -H "apikey: $API_KEY" \
  -H "Authorization: Bearer $API_KEY" \
  "https://lhcjobrtmbawlhjyodxz.supabase.co/rest/v1/moments?select=count()" \
  2>&1 | head -20

echo ""
echo "=== Moments from last 10 days (April 10-20) ==="
curl -s -H "apikey: $API_KEY" \
  -H "Authorization: Bearer $API_KEY" \
  "https://lhcjobrtmbawlhjyodxz.supabase.co/rest/v1/moments?select=id,user_id,created_at&order=created_at.desc&limit=50&created_at=gte.2026-04-10T00:00:00Z" \
  2>&1 | jq 'length, .[0:5]'
