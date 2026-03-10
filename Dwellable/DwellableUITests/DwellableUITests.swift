//
//  DwellableUITests.swift
//  DwellableUITests
//
//  Created by Michael Golden on 3/9/26.
//

import XCTest

final class DwellableUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    @MainActor
    func testValidLogin() throws {
        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
        emailField.tap()
        emailField.typeText("test.normal@example.com")

        let passwordField = app.secureTextFields["Password"]
        XCTAssertTrue(passwordField.exists)
        passwordField.tap()
        passwordField.typeText("password123")

        let loginButton = app.buttons["Login"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()

        let momentsList = app.tables["MomentsList"]
        let exists = momentsList.waitForExistence(timeout: 15)
        XCTAssertTrue(exists, "MomentsListView should appear after successful login")
    }

    @MainActor
    func testLoginWithEmptyFields() throws {
        let loginButton = app.buttons["Login"]
        loginButton.tap()

        let emailField = app.textFields["Email"]
        XCTAssertTrue(emailField.exists)
    }

    @MainActor
    func testCreateTextMoment() throws {
        loginWithValidCredentials()

        let typeButton = app.buttons["Type instead"]
        XCTAssertTrue(typeButton.exists)
        typeButton.tap()

        let textField = app.textViews["moment_body"]
        XCTAssertTrue(textField.exists)
        textField.tap()
        textField.typeText("This is a test moment created via XCUITest")

        let senseField = app.textFields["sense_of_lord"]
        if senseField.exists {
            senseField.tap()
            senseField.typeText("In the test framework itself")
        }

        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        let momentsList = app.tables["MomentsList"]
        let exists = momentsList.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Should return to MomentsListView after save")
    }

    @MainActor
    func testFetchAndDisplayMoments() throws {
        loginWithValidCredentials()

        let momentsList = app.tables["MomentsList"]
        let exists = momentsList.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Moments list should load")

        let firstMoment = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(firstMoment.exists, "At least one moment should exist")
    }

    @MainActor
    func testSessionPersistenceAfterRestart() throws {
        loginWithValidCredentials()

        let momentsList = app.tables["MomentsList"]
        XCTAssertTrue(momentsList.exists)

        app.terminate()
        app.launch()

        let momentsListAfterRestart = app.tables["MomentsList"]
        let exists = momentsListAfterRestart.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "User should be logged in after app restart")
    }

    @MainActor
    func testNavigationBetweenScreens() throws {
        loginWithValidCredentials()

        let captureButton = app.buttons["Capture moment"]
        XCTAssertTrue(captureButton.exists)
        captureButton.tap()

        let typeButton = app.buttons["Type instead"]
        let typeExists = typeButton.waitForExistence(timeout: 3)
        XCTAssertTrue(typeExists, "Should navigate to CaptureView")
    }

    private func loginWithValidCredentials() {
        let emailField = app.textFields["Email"]
        emailField.tap()
        emailField.typeText("test.normal@example.com")

        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("password123")

        let loginButton = app.buttons["Login"]
        loginButton.tap()

        let momentsList = app.tables["MomentsList"]
        // Give more time for async login + view transition (Keychain + API call)
        _ = momentsList.waitForExistence(timeout: 15)
    }
}
