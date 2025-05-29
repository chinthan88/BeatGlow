//
//  Untitled.swift
//  BeatGlow
//
//  Created by Chinthan M on 28/05/25.
//

import SwiftUI

/// Protocol defining smart light control behavior.
protocol LightManagerProtocol {

    /// Sets the static light color.
    /// - Parameter color: The color to set.
    func setColor(_ color: Color)

    /// Flashes the light on beat detection.
    func flashOnBeat()

    /// Updates the light's brightness and color.
    /// - Parameters:
    ///   - brightness: Brightness level (0.0–1.0).
    ///   - color: The color to apply.
    func updateColor(brightness: Float, color: Color)
}
