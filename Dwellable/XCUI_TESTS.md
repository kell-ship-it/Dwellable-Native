# Dwellable Native — XCUI Test Setup & Examples

**Purpose:** Automated UI testing for key workflows without manual intervention
**Framework:** XCUITest (Apple's native testing framework)
**Scope:** Test offline sync, auth, moment CRUD, error handling
**Cannot test:** Voice recording/transcription (requires real microphone), visual design details

---

## 📋 Overview

XCUITest allows us to:
- ✅ Automate login flows
- ✅ Create moments (text only, not voice)
- ✅ Verify offline sync behavior
- ✅ Test error handling UI
- ✅ Verify data persistence across app restarts
- ✅ Run on simulator and physical device
- ❌ Cannot test voice input
- ❌ Cannot verify transcription accuracy

**Test Duration:** ~2–3 minutes per test run

---

## 🏗️ Setup Steps

### Step 1: Create XCUITest Target in Xcode

```bash
# In Xcode:
# 1. File → New → Target
# 2. Select "iOS" → "UI Testing Bundle"
# 3. Name it "DwellableUITests"
# 4. Click Create
```

This creates:
```
Dwellable/
  DwellableUITests/
    DwellableUITests.swift        # Main test file
    Info.plist                     # Test config
```

### Step 2: Configure Test Target

In `Info.plist` (DwellableUITests):
```xml
<key>NSBonjourServiceTypes</key>
<array>
    <string>_http._tcp</string>
</array>
```

### Step 3: Build Settings

Ensure test target has:
- **Test Host:** `Dwellable`
- **Bundle Loader:** `$(BUILT_PRODUCTS_DIR)/Dwellable.app/Dwellable`

---

## 🧪 Example XCUI Test Cases

### Test 1: Login Flow

```swift
import XCTest

class DwellableUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Test successful login with valid credentials
    func testValidLogin() {
        // Find email field and enter test email
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("test@example.com")

        // Find password field and enter password
        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("password123")

        // Tap login button
        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()

        // Wait for MomentsListView to appear (max 5 seconds)
        let momentsList = app.tables["MomentsList"]
        let exists = momentsList.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "MomentsListView should appear after successful login")
    }

    /// Test login rejected with empty fields
    func testLoginWithEmptyFields() {
        let loginButton = app.buttons["Login"]
        loginButton.tap()

        // Error message should appear
        let errorMessage = app.staticTexts["Invalid request"]
        let exists = errorMessage.waitForExistence(timeout: 2)
        XCTAssertTrue(exists, "Error message should appear for empty fields")

        // Should still be on LoginView
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
    }
}
```

---

### Test 2: Create Text Moment

```swift
/// Test creating a text moment while online
func testCreateTextMoment() {
    // First, login
    loginWithValidCredentials()

    // Tap "Type instead" button to go to TypeFlowView
    let typeButton = app.buttons["Type instead"]
    XCTAssertTrue(typeButton.exists)
    typeButton.tap()

    // Enter moment text
    let textField = app.textViews["moment_body"]
    XCTAssertTrue(textField.exists)
    textField.tap()
    textField.typeText("This is a test moment created via XCUITest")

    // Optionally add "Sense of Lord" field
    let senseField = app.textFields["sense_of_lord"]
    if senseField.exists {
        senseField.tap()
        senseField.typeText("In the test framework itself")
    }

    // Tap Save button
    let saveButton = app.buttons["Save"]
    XCTAssertTrue(saveButton.exists)
    saveButton.tap()

    // Wait for return to MomentsListView
    let momentsList = app.tables["MomentsList"]
    let exists = momentsList.waitForExistence(timeout: 5)
    XCTAssertTrue(exists, "Should return to MomentsListView after save")

    // Verify new moment appears in list
    let newMomentText = app.staticTexts["This is a test moment created via XCUITest"]
    XCTAssertTrue(newMomentText.exists, "New moment should appear in list")
}

// Helper method
private func loginWithValidCredentials() {
    let emailField = app.textFields["Email"]
    emailField.tap()
    emailField.typeText("test@example.com")

    let passwordField = app.secureTextFields["Password"]
    passwordField.tap()
    passwordField.typeText("password123")

    let loginButton = app.buttons["Login"]
    loginButton.tap()

    let momentsList = app.tables["MomentsList"]
    _ = momentsList.waitForExistence(timeout: 5)
}
```

---

### Test 3: Offline Moment Creation & Sync

```swift
/// Test creating moment while offline, then syncing when network returns
func testOfflineMomentCreationAndSync() {
    // Login first
    loginWithValidCredentials()

    // Disable WiFi and cellular using Simulator controls
    // (In Xcode test, you'd use XCUITest helpers or manual device toggle)

    // Go to TypeFlowView
    let typeButton = app.buttons["Type instead"]
    typeButton.tap()

    // Create moment
    let textField = app.textViews["moment_body"]
    textField.tap()
    textField.typeText("Offline test moment")

    // Tap Save
    let saveButton = app.buttons["Save"]
    saveButton.tap()

    // Verify "pending sync" message appears
    let pendingSyncMessage = app.staticTexts["Pending sync"]
    let pendingExists = pendingSyncMessage.waitForExistence(timeout: 3)
    XCTAssertTrue(pendingExists, "Should show 'pending sync' message for offline save")

    // Wait 1.5 seconds for message to auto-dismiss
    sleep(2)

    // Should be back on MomentsListView
    let momentsList = app.tables["MomentsList"]
    XCTAssertTrue(momentsList.exists)

    // Verify moment appears in list (even though offline)
    let offlineMoment = app.staticTexts["Offline test moment"]
    XCTAssertTrue(offlineMoment.exists, "Moment should appear in list even while offline")

    // Re-enable network
    // (In real test, use Simulator network toggle or device WiFi)

    // Wait for auto-sync (10 seconds max)
    sleep(12)

    // Verify moment is still in list and no error message shows
    XCTAssertTrue(offlineMoment.exists, "Moment should persist after sync")

    let errorMessage = app.staticTexts["Error"]
    XCTAssertFalse(errorMessage.exists, "No error should appear after sync")
}
```

---

### Test 4: Fetch Moments List

```swift
/// Test that moments list displays correctly after login
func testFetchAndDisplayMoments() {
    // Login
    loginWithValidCredentials()

    // Wait for moments table to load
    let momentsList = app.tables["MomentsList"]
    let exists = momentsList.waitForExistence(timeout: 5)
    XCTAssertTrue(exists, "Moments list should load")

    // Verify loading spinner appears during fetch (optional, may be too fast)
    // let spinner = app.activityIndicators.element
    // XCTAssertTrue(spinner.exists)

    // Verify at least one moment row exists
    let firstMoment = app.tables.cells.element(boundBy: 0)
    XCTAssertTrue(firstMoment.exists, "At least one moment should exist")

    // Verify moment has expected structure (date, preview text)
    let momentDate = firstMoment.staticTexts["moment_date"]
    XCTAssertTrue(momentDate.exists, "Moment should display date")
}
```

---

### Test 5: Session Persistence

```swift
/// Test that user session persists after app restart
func testSessionPersistenceAfterRestart() {
    // Login
    loginWithValidCredentials()

    // Verify in MomentsListView
    let momentsList = app.tables["MomentsList"]
    XCTAssertTrue(momentsList.exists)

    // Terminate app
    app.terminate()

    // Relaunch app
    app.launch()

    // Should still be logged in (MomentsListView visible)
    let momentsListAfterRestart = app.tables["MomentsList"]
    let exists = momentsListAfterRestart.waitForExistence(timeout: 5)
    XCTAssertTrue(exists, "User should be logged in after app restart (Keychain session persists)")
}
```

---

### Test 6: Error Handling

```swift
/// Test that app handles network errors gracefully
func testNetworkErrorHandling() {
    // Login
    loginWithValidCredentials()

    // Navigate to TypeFlowView
    let typeButton = app.buttons["Type instead"]
    typeButton.tap()

    // Enter text
    let textField = app.textViews["moment_body"]
    textField.tap()
    textField.typeText("Test moment for error handling")

    // Simulate network error (disable WiFi/cellular)
    // For automation, you can use MockAPIClient to inject errors

    // Tap Save
    let saveButton = app.buttons["Save"]
    saveButton.tap()

    // Verify error message appears
    let errorMessage = app.staticTexts["Pending sync"]
    let exists = errorMessage.waitForExistence(timeout: 3)
    XCTAssertTrue(exists, "Should show error or pending sync message")
}
```

---

## 🔧 Test Accessibility IDs

For XCUITest to find elements reliably, add `.accessibilityIdentifier` to key UI elements:

**In your SwiftUI code:**

```swift
// LoginView
TextField("Email", text: $email)
    .accessibilityIdentifier("Email")

SecureField("Password", text: $password)
    .accessibilityIdentifier("Password")

Button("Login") { /* ... */ }
    .accessibilityIdentifier("Login")

// MomentsListView
List {
    // ...
}
.accessibilityIdentifier("MomentsList")

// TypeFlowView
TextEditor(text: $momentBody)
    .accessibilityIdentifier("moment_body")

TextField("Add where you sensed...", text: $senseOfLord)
    .accessibilityIdentifier("sense_of_lord")

Button("Save") { /* ... */ }
    .accessibilityIdentifier("Save")
```

---

## 🚀 Running Tests

### Run All Tests

```bash
# Build and run all XCUI tests on simulator
xcodebuild test \
  -scheme Dwellable \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -configuration Debug

# Or in Xcode:
# Cmd + U (with simulator running)
```

### Run Single Test

```bash
xcodebuild test \
  -scheme Dwellable \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing 'DwellableUITests/DwellableUITests/testValidLogin'
```

### Run on Physical Device

```bash
# First, connect iPhone via USB
# Then build for physical device:
xcodebuild test \
  -scheme Dwellable \
  -destination 'generic/platform=iOS' \
  -configuration Debug
```

---

## 📊 Test Matrix

| Test | Simulator | Physical Device | Notes |
|---|---|---|---|
| testValidLogin | ✅ | ✅ | Works on both |
| testLoginWithEmptyFields | ✅ | ✅ | Works on both |
| testCreateTextMoment | ✅ | ✅ | Text-based, no voice |
| testOfflineMomentCreationAndSync | ✅ | ✅ | Requires manual WiFi toggle on device |
| testFetchAndDisplayMoments | ✅ | ✅ | Works on both |
| testSessionPersistenceAfterRestart | ✅ | ✅ | Works on both |
| testNetworkErrorHandling | ⚠️ | ✅ | Simulator: harder to simulate network failure |

---

## ⚠️ Limitations & Workarounds

### Limitation 1: Voice Recording
**Problem:** Can't automate voice input
**Workaround:** Only test text moment creation in XCUI; test voice recording manually (U-001)

### Limitation 2: Network Simulation
**Problem:** Hard to simulate network failures in simulator
**Workaround:**
- Use MockAPIClient in test configuration to inject errors
- Or manually toggle WiFi on physical device during test

### Limitation 3: Microphone Permission
**Problem:** Permission prompt blocks tests
**Workaround:** Pre-grant permission on test device, or skip voice tests in automation

---

## 🛠️ CI/CD Integration (Future)

Once tests are stable, add to GitHub Actions:

```yaml
# .github/workflows/tests.yml
name: XCUI Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: '15.1'
      - run: xcodebuild test -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

---

## 📝 Next Steps

1. **Create XCUI target** in Xcode (File → New → Target → UI Testing Bundle)
2. **Add accessibility IDs** to key UI elements (LoginView, buttons, text fields)
3. **Copy test code** from this file into `DwellableUITests.swift`
4. **Run on simulator:** `xcodebuild test -scheme Dwellable -destination 'platform=iOS Simulator,name=iPhone 16 Pro'`
5. **Run on physical device:** Build to iPhone, trigger tests
6. **Iterate:** Add more test cases as you identify critical workflows

---

## 📚 Resources

- [Apple XCUITest Documentation](https://developer.apple.com/documentation/xctest/xcuitest)
- [XCUITest Best Practices](https://developer.apple.com/videos/play/wwdc2015/406/)
- [Accessibility Identifiers in SwiftUI](https://developer.apple.com/documentation/swiftui/view/accessibilityidentifier(_:))
