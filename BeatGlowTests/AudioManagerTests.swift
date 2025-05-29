//
//  BeatGlowTests.swift
//  BeatGlowTests
//
//  Created by Chinthan M on 26/05/25.
//

import XCTest
import Combine
import SwiftUI

class AudioManagerTests: XCTestCase {

    var sut: AudioManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = AudioManager()
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    func testMicrophonePermission_granted() {
        let expectation = self.expectation(description: "Permission granted")
        sut.requestMicrophonePermission { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testStart_withoutPermission_shouldNotStart() {
        sut.start()
    }

    func testPause_andResumeEngine() {
        sut.requestMicrophonePermission { _ in }
        sut.pause()
        sut.resume()
    }

    func testStopEngine_shouldDeactivateSessionAndStopEngine() {
        sut.stop()
        // The engine should be stopped and output should be nil
    }

    func testAmplitudePublisher_shouldEmitValues() {
        let expectation = self.expectation(description: "Amplitude emitted")
        var receivedAmplitude: Float?

        sut.amplitudePublisher
            .sink { value in
                receivedAmplitude = value
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // Simulate amplitude
        sut.performTestableHandleAmplitude(0.3)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedAmplitude, 0.3)
    }

    func testDominantColorPublisher_shouldEmitCorrectColor() {
        let expectation = self.expectation(description: "Color emitted")

        sut.dominantColorPublisher
            .sink { color in
                XCTAssertEqual(color, Color.orange)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.performTestableHandleAmplitude(0.2)

        wait(for: [expectation], timeout: 1.0)
    }

    func testColorForAmplitude() {
        XCTAssertEqual(sut.performTestableColorForAmplitude(0.05), Color.pink.opacity(0.7))
        XCTAssertEqual(sut.performTestableColorForAmplitude(0.2), Color.orange)
        XCTAssertEqual(sut.performTestableColorForAmplitude(0.4), Color.yellow)
        XCTAssertEqual(sut.performTestableColorForAmplitude(0.7), Color.red)
    }
}

extension AudioManager {
    func performTestableHandleAmplitude(_ amplitude: Float) {
        handleAmplitude(amplitude)
    }

    func performTestableColorForAmplitude(_ amplitude: Float) -> Color {
        colorForAmplitude(amplitude)
    }
}
