#!/bin/bash

# Dwellable Test Account Generator
# Creates 10 test accounts in Supabase for participant testing
#
# USAGE:
#   1. Get your Supabase service role key (see instructions below)
#   2. Run: bash generate-test-accounts.sh <your-service-role-key>
#
# TO GET SERVICE ROLE KEY:
#   1. Go to https://app.supabase.com/projects
#   2. Select your Dwellable project
#   3. Go to Settings → API → Service Role Key
#   4. Copy the key (keep it secret!)
#   5. Run this script: bash generate-test-accounts.sh <paste-key-here>

set -e

# Configuration
SUPABASE_URL="https://lhcjobrtmbawlhjyodxz.supabase.co"
SERVICE_ROLE_KEY="$1"
BASE_PASSWORD="ParticipantTest123"
NUM_ACCOUNTS=10

# Validate input
if [ -z "$SERVICE_ROLE_KEY" ]; then
    echo "❌ Error: Service role key not provided"
    echo ""
    echo "Usage: bash generate-test-accounts.sh <service-role-key>"
    echo ""
    echo "To get your service role key:"
    echo "  1. Go to https://app.supabase.com/projects"
    echo "  2. Select Dwellable project"
    echo "  3. Settings → API → Service Role Key (copy it)"
    echo "  4. Run: bash generate-test-accounts.sh <paste-key-here>"
    exit 1
fi

echo "🔨 Generating $NUM_ACCOUNTS test accounts..."
echo ""

# Track created accounts
created_accounts=()
failed_accounts=()

for i in $(seq 1 $NUM_ACCOUNTS); do
    email="participant${i}@dwellable.test"
    password="$BASE_PASSWORD"

    echo "Creating account $i of $NUM_ACCOUNTS: $email..."

    # Call Supabase Admin API to create user
    response=$(curl -s -X POST "${SUPABASE_URL}/auth/v1/admin/users" \
        -H "apikey: ${SERVICE_ROLE_KEY}" \
        -H "Authorization: Bearer ${SERVICE_ROLE_KEY}" \
        -H "Content-Type: application/json" \
        -d "{
            \"email\": \"${email}\",
            \"password\": \"${password}\",
            \"email_confirm\": true,
            \"user_metadata\": {
                \"participant_number\": ${i}
            }
        }")

    # Check if user was created successfully
    if echo "$response" | grep -q "\"id\""; then
        echo "  ✅ Created: $email"
        created_accounts+=("$email:$password")
    else
        echo "  ❌ Failed: $email"
        echo "  Response: $response"
        failed_accounts+=("$email")
    fi

    # Small delay to avoid rate limiting
    sleep 0.5
done

echo ""
echo "================================"
echo "📊 Summary"
echo "================================"
echo "✅ Created: ${#created_accounts[@]} accounts"
echo "❌ Failed: ${#failed_accounts[@]} accounts"
echo ""

if [ ${#created_accounts[@]} -gt 0 ]; then
    echo "✅ Successfully Created Accounts:"
    echo ""
    for account in "${created_accounts[@]}"; do
        email="${account%:*}"
        password="${account#*:}"
        echo "  Email:    $email"
        echo "  Password: $password"
        echo ""
    done
fi

if [ ${#failed_accounts[@]} -gt 0 ]; then
    echo "❌ Failed Accounts:"
    for account in "${failed_accounts[@]}"; do
        echo "  - $account"
    done
    echo ""
    echo "💡 Tip: Check if service role key is correct and has sufficient permissions"
fi

echo "================================"
echo ""
echo "✨ Next Steps:"
echo "  1. Verify accounts in Supabase dashboard:"
echo "     https://app.supabase.com/projects/lhcjobrtmbawlhjyodxz/auth/users"
echo "  2. Test login with one account in the app"
echo "  3. Share account list with participants"
echo ""
