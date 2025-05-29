//
//  ViewModelTests.swift
//  BeatGlow
//
//  Created by Chinthan M on 28/05/25.
//

import XCTest
import Combine
import SwiftUI

final class PartyModeViewModelTests: XCTestCase {
    var viewModel: PartyModeViewModel!
    var mockAudioManager: MockAudioManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAudioManager = MockAudioManager()
        viewModel = PartyModeViewModel(audioManager: mockAudioManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAudioManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testAmplitudeUpdates() {
        let expectation = XCTestExpectation(description: "Amplitude updates")
        viewModel.$amplitude
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, 0.75)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockAudioManager.amplitudeSubject.send(0.75)
        wait(for: [expectation], timeout: 1)
    }

    func testDominantColorUpdates() {
        let expectation = XCTestExpectation(description: "Color updates")
        viewModel.$dominantColor
            .dropFirst()
            .sink { color in
                XCTAssertEqual(color, .blue)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        mockAudioManager.colorSubject.send(.blue)
        wait(for: [expectation], timeout: 1)
    }

    func testBeatDetection() {
        let beatDetected = XCTestExpectation(description: "Beat detected true")
        let beatReset = XCTestExpectation(description: "Beat detected false")

        var values: [Bool] = []
        viewModel.$isBeatDetected
            .dropFirst()
            .sink { val in
                values.append(val)
                if values.count == 1 && val == true {
                    beatDetected.fulfill()
                } else if values.count == 2 && val == false {
                    beatReset.fulfill()
                }
            }
            .store(in: &cancellables)

        mockAudioManager.beatSubject.send()
        wait(for: [beatDetected, beatReset], timeout: 1.0)
    }

    func testStartCallsAudioManager() {
        viewModel.start()
        XCTAssertTrue(mockAudioManager.startCalled)
    }

    func testStopCallsAudioManager() {
        viewModel.stop()
        XCTAssertTrue(mockAudioManager.stopCalled)
    }

    func testPauseCallsAudioManager() {
        viewModel.pause()
        XCTAssertTrue(mockAudioManager.pauseCalled)
    }

    func testResumeCallsAudioManager() {
        viewModel.resume()
        XCTAssertTrue(mockAudioManager.resumeCalled)
    }

    func test_checkMicrophonePermissionAndStart_granted() {
        let expectation = XCTestExpectation(description: "Permission granted flow")

        mockAudioManager.microphonePermissionResult = true

        viewModel.$isRunning
            .dropFirst()
            .sink { isRunning in
                XCTAssertTrue(self.mockAudioManager.startCalled)
                XCTAssertTrue(isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.checkMicrophonePermissionAndStart()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_checkMicrophonePermissionAndStart_denied() {
        let expectation = XCTestExpectation(description: "Permission denied flow")

        mockAudioManager.microphonePermissionResult = false

        viewModel.$showMicrophoneAlert
            .dropFirst()
            .sink { showAlert in
                XCTAssertTrue(showAlert)
                XCTAssertFalse(self.viewModel.isRunning)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.checkMicrophonePermissionAndStart()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_toggleVisualizer_startAndPause() {
        viewModel.isRunning = false
        viewModel.toggleVisualizer()
        XCTAssertTrue(mockAudioManager.resumeCalled)
        XCTAssertTrue(viewModel.isRunning)

        viewModel.toggleVisualizer()
        XCTAssertTrue(mockAudioManager.pauseCalled)
        XCTAssertFalse(viewModel.isRunning)
    }

    func test_stopVisualizer() {
        viewModel.isRunning = true
        viewModel.stopVisualizer()
        XCTAssertTrue(mockAudioManager.stopCalled)
        XCTAssertFalse(viewModel.isRunning)
    }

    func testRequestMicrophonePermissionGranted() {
        let expectation = XCTestExpectation(description: "Permission granted")
        mockAudioManager.microphonePermissionResult = true

        viewModel.requestMicrophonePermission { granted in
            XCTAssertTrue(granted)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testRequestMicrophonePermissionDenied() {
        let expectation = XCTestExpectation(description: "Permission denied")
        mockAudioManager.microphonePermissionResult = false

        viewModel.requestMicrophonePermission { granted in
            XCTAssertFalse(granted)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testUpdateHueCalledWithCorrectValues() {
        // Arrange
        let mockAudioManager = MockAudioManager()
        let mockHueManager = MockLightManager()
        let partyModeViewModel  = PartyModeViewModel(audioManager: mockAudioManager,
                                           hueManager: mockHueManager)

        let testAmplitude: Float = 0.75
        let testColor: Color = .blue

        // Act
        mockAudioManager.amplitudeSubject.send(testAmplitude)
        mockAudioManager.colorSubject.send(testColor)

        // Allow async processing
        RunLoop.main.run(until: Date().addingTimeInterval(3))

        // Assert
        XCTAssertEqual(mockHueManager.updateColorCalledWith?.brightness, testAmplitude)
        XCTAssertEqual(mockHueManager.updateColorCalledWith?.color.description, testColor.description)
    }
}
