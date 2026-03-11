# Test Account Setup for Dwellable Participants

**Purpose:** Generate 10 test accounts for participant testing
**Task:** U-004 in USER_ACTIVITIES.md
**Time:** 5 minutes

---

## Step 1️⃣ — Get Your Service Role Key

This is a secret key that allows the script to create users in Supabase. **Keep it secret!**

### 1.1 Open Supabase Dashboard

Go to: https://app.supabase.com/projects

### 1.2 Select Your Dwellable Project

Click on the **Dwellable** project (lhcjobrtmbawlhjyodxz)

### 1.3 Navigate to API Keys

In the left sidebar:
1. Click **Settings** (gear icon)
2. Click **API** in the dropdown menu
3. You'll see:
   - **Project URL** (public)
   - **Anon Key** (public, publishable)
   - **Service Role Key** (SECRET — keep private!)

### 1.4 Copy Service Role Key

Look for **"Service Role Key"** section:
- Click the **copy icon** next to it
- **DON'T share this key with anyone**
- Store it temporarily for this script only

---

## Step 2️⃣ — Run the Account Generation Script

Open Terminal and run:

```bash
cd /Users/kell/Projects/Dwellable-Native/Dwellable
bash generate-test-accounts.sh <paste-service-role-key-here>
```

Replace `<paste-service-role-key-here>` with the actual key you copied.

**Example:**
```bash
bash generate-test-accounts.sh sbp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 2.1 What the Script Does

- ✅ Creates 10 test accounts
- ✅ Auto-confirms email (no verification needed)
- ✅ Uses consistent password for all: `ParticipantTest123`
- ✅ Adds participant metadata (participant number)
- ✅ Shows success/failure for each account
- ✅ Prints account list at the end

### 2.2 What You'll See

```
🔨 Generating 10 test accounts...

Creating account 1 of 10: participant1@dwellable.test...
  ✅ Created: participant1@dwellable.test
Creating account 2 of 10: participant2@dwellable.test...
  ✅ Created: participant2@dwellable.test
[... continues for all 10 ...]

================================
📊 Summary
================================
✅ Created: 10 accounts
❌ Failed: 0 accounts

✅ Successfully Created Accounts:

  Email:    participant1@dwellable.test
  Password: ParticipantTest123

  Email:    participant2@dwellable.test
  Password: ParticipantTest123
[... continues ...]
```

---

## Step 3️⃣ — Verify Accounts Were Created

### 3.1 Check in Supabase Dashboard

1. Go to: https://app.supabase.com/projects
2. Select **Dwellable** project
3. Click **Authentication** in left sidebar
4. Click **Users** tab
5. You should see 10 new accounts:
   - participant1@dwellable.test
   - participant2@dwellable.test
   - ... participant10@dwellable.test

### 3.2 Test Login in the App

1. Build app to simulator or device
2. On LoginView, try:
   - **Email:** `participant1@dwellable.test`
   - **Password:** `ParticipantTest123`
3. Tap **Sign In**
4. Should see MomentsListView (success!)

---

## Step 4️⃣ — Share Accounts with Participants

Create a simple list for each participant:

```
🎉 Welcome to Dwellable Testing!

Your test account:
  Email:    participant1@dwellable.test
  Password: ParticipantTest123

Build the app to your iPhone and log in with these credentials.
```

---

## 🔐 Security Notes

- ✅ Service Role Key: **Keep secret** — don't share, don't commit to git
- ✅ Delete the service role key from your terminal history after use
- ✅ Passwords are the same for simplicity (all `ParticipantTest123`)
- ✅ For real production, use unique passwords per user

### After Script Completes

1. Delete the service role key from your terminal history
2. Or create a `.env` file (git-ignored) to store it
3. Never commit the key to GitHub

---

## 🆘 Troubleshooting

### "Service role key not provided"

**Fix:** You forgot to pass the key as an argument

```bash
bash generate-test-accounts.sh <your-key-here>
```

### "Permission denied" error

**Fix:** Make the script executable first

```bash
chmod +x generate-test-accounts.sh
```

### "Failed: participant1@dwellable.test"

**Possible causes:**
- ❌ Service role key is invalid
- ❌ Service role key doesn't have permission to create users
- ❌ Account already exists (try changing email address)

**Fix:**
- Verify service role key is correct (copy again from dashboard)
- Check Supabase dashboard for error details

### "Email address is invalid"

The `.test` TLD might be rejected by some systems. Change in the script:
- Edit line: `email="participant${i}@dwellable.test"`
- Change to: `email="participant${i}@example.com"`

---

## 📝 Script Details

**Location:** `/Users/kell/Projects/Dwellable-Native/Dwellable/generate-test-accounts.sh`

**API Endpoint Used:**
```
POST /auth/v1/admin/users
```

**Account Details:**
- Emails: participant1–participant10 (with @dwellable.test domain)
- Password: ParticipantTest123 (same for all)
- Email confirmed: Yes (auto-confirmed, no verification needed)
- Metadata: participant_number (1-10)

**Accounts are immediately usable** — no email confirmation required.

---

## ✅ Acceptance Criteria for U-004

- [ ] Service role key obtained from Supabase
- [ ] Script executed successfully
- [ ] 10 accounts created (check dashboard)
- [ ] Test login with participant1 account
- [ ] Account list ready to share with participants

**Next:** Share the account credentials with your testing participants!

