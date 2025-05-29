//
//  MockLightManager.swift
//  BeatGlow
//
//  Created by Chinthan M on 28/05/25.
//
import SwiftUI
import XCTest

final class MockLightManager: LightManagerProtocol {
    var setColorCalledWith: Color?
    var flashOnBeatCalled = false
    var updateColorCalledWith: (brightness: Float, color: Color)?

    func setColor(_ color: Color) {
        setColorCalledWith = color
    }

    func flashOnBeat() {
        flashOnBeatCalled = true
    }

    func updateColor(brightness: Float, color: Color) {
        updateColorCalledWith = (brightness, color)
    }
}
