//
//  PartyModeViewModel.swift
//  BeatGlow
//
//  Created by Chinthan M on 26/05/25.
//

import SwiftUI
import Combine

/// ViewModel responsible for managing audio-reactive party mode state.
final class PartyModeViewModel: ObservableObject {

    // MARK: - Dependencies

    private let audioManager: AudioManagerProtocol
    private let lightManager: LightManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    private var previousAmplitude: Float = 0.0
    private let amplitudeThreshold: Float = 0.05 // Set the threshold for detecting significant changes

    // MARK: - Published Properties

    @Published var amplitude: Float = 0.0
    @Published var dominantColor: Color = .pink
    @Published var isBeatDetected: Bool = false
    @Published var isRunning = false
    @Published var showMicrophoneAlert = false

    // MARK: - Initialization

    /// Initializes the view model with an audio manager.
    /// - Parameter audioManager: The manager used to receive audio events.
    init(audioManager: AudioManagerProtocol = AudioManager(),
         hueManager: LightManagerProtocol = LightManager()) {
        self.audioManager = audioManager
        self.lightManager = hueManager
        bindAmplitude()
        bindBeatDetection()
        bindDominantColor()
    }

    // MARK: - Publisher Bindings

    /// Subscribes to amplitude updates.
    private func bindAmplitude() {
        audioManager.amplitudePublisher
            .throttle(for: .milliseconds(300), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] amplitude in
                guard let self = self else { return }
                if abs(amplitude - self.previousAmplitude) > self.amplitudeThreshold {
                    self.amplitude = amplitude
                    self.updateLight()
                    print("self?.amplitude: \(String(describing: self.amplitude))")
                }
            }
            .store(in: &cancellables)
    }

    /// Subscribes to beat detection events.
    private func bindBeatDetection() {
        audioManager.beatDetectedPublisher
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in
                self?.handleBeatDetected()
            }
            .store(in: &cancellables)
    }

    /// Handles beat detection UI state.
    private func handleBeatDetected() {
        isBeatDetected = true
        lightManager.flashOnBeat()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isBeatDetected = false
        }
    }

    /// Subscribes to dominant color updates.
    private func bindDominantColor() {
        audioManager.dominantColorPublisher
            .removeDuplicates()
            .throttle(for: .milliseconds(2000), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] color in
                self?.dominantColor = color
                self?.lightManager.setColor(color)
                self?.updateLight()
            }
            .store(in: &cancellables)
    }

    /// Update light with Hue.
    private func updateLight() {
        lightManager.updateColor(brightness: amplitude, color: dominantColor)
    }

    // MARK: - Audio Control Methods

    /// Starts audio monitoring.
    func start() {
        audioManager.start()
    }

    /// Stops audio monitoring.
    func stop() {
        audioManager.stop()
    }

    /// Pauses audio processing.
    func pause() {
        audioManager.pause()
    }

    /// Resumes audio processing.
    func resume() {
        audioManager.resume()
    }

    /// Check Microphone Permission
    func checkMicrophonePermissionAndStart() {
        requestMicrophonePermission { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.start()
                    self?.isRunning = true
                } else {
                    self?.showMicrophoneAlert = true
                }
            }
        }
    }

    /// Toggle Visualizer
    func toggleVisualizer() {
        if isRunning {
            pause()
        } else {
            resume()
        }
        isRunning.toggle()
    }

    /// Stop Visualizer
    func stopVisualizer() {
        stop()
        isRunning = false
    }

    // MARK: - Permissions

    /// Requests microphone access permission.
    /// - Parameter completion: Callback with permission result.
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        audioManager.requestMicrophonePermission(completion: completion)
    }
}
