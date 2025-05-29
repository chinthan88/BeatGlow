//
//  HueManager.swift
//  BeatGlow
//
//  Created by Chinthan M on 26/05/25.
//

import SwiftUI

/// Default implementation of `LightManagerProtocol` for managing smart light updates.
final class LightManager: LightManagerProtocol {

    /// Sets the static light color.
    /// - Parameter color: The color to apply to the Hue light.
    func setColor(_ color: Color) {
        print("LightManager -> setColor called with: \(color)")
        // TODO: Send static color command to Hue Bridge
    }

    /// Triggers a flash effect on beat detection.
    func flashOnBeat() {
        print("LightManager -> flashOnBeat triggered!")
        // TODO: Implement flashing logic for beat effect
    }

    /// Updates the light color and brightness based on amplitude.
    /// - Parameters:
    ///   - brightness: Normalized brightness (0.0–1.0).
    ///   - color: The color to apply.
    func updateColor(brightness: Float, color: Color) {
        let brightnessPercent = Int(min(max(brightness * 100, 10), 100))
        print("LightManager -> Brightness: \(brightnessPercent)% | Color: \(color)")
        // TODO: Implement Signify Hue Bridge update logic here
    }
}
