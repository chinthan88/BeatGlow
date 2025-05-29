//
//  PartyModeUITests.swift
//  BeatGlow
//
//  Created by Chinthan M on 29/05/25.
//
import XCTest

final class PartyModeUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }

    func testPartyModeView_UIElementsExistAndToggle() {
        // Wait for UI to load
        let title = app.staticTexts["titleText"]
        XCTAssertTrue(title.waitForExistence(timeout: 5), "BeatGlow title should be visible")

        let beatCircle = app.otherElements["beatIndicatorCircle"]
        XCTAssertTrue(beatCircle.exists, "Beat indicator circle should be present")

        let button = app.buttons["controlButton"]
        XCTAssertTrue(button.exists, "Start/Stop button should be present")

        // Tap to Start Visualizer
        let startTitle = button.label
        XCTAssertEqual(startTitle, "Stop", "Button should initially show 'Stop'")
        button.tap()

        // Give it time to process state change
        sleep(1)

        // Tap to Stop Visualizer
        XCTAssertEqual(button.label, "Start", "Button should now show 'Start'")
        button.tap()
        sleep(1)
        XCTAssertEqual(button.label, "Stop", "Button should revert to 'Stop'")
    }

}
