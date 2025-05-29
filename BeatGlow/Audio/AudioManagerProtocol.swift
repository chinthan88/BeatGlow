//
//  AudioManagerProtocol.swift
//  BeatGlow
//
//  Created by Chinthan M on 27/05/25.
//
import Foundation
import AVFoundation
import AudioKit
import Combine
import SwiftUI

// MARK: - AudioManagerProtocol

/// A protocol for managing audio input, detecting beats, and publishing audio events.
protocol AudioManagerProtocol {

    /// Publishes audio amplitude values (0.0–1.0).
    var amplitudePublisher: AnyPublisher<Float, Never> { get }

    /// Publishes an event when a beat is detected.
    var beatDetectedPublisher: AnyPublisher<Void, Never> { get }

    /// Publishes the dominant color extracted from the audio signal.
    var dominantColorPublisher: AnyPublisher<Color, Never> { get }

    /// Starts audio processing.
    func start()

    /// Stops audio processing.
    func stop()

    /// Pauses audio analysis without releasing resources.
    func pause()

    /// Resumes audio analysis after a pause.
    func resume()

    /// Requests microphone access permission.
    /// - Parameter completion: A closure with a `Bool` indicating permission status.
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void)
}
