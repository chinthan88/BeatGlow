//
//  AudioManager.swift
//  BeatGlow
//
//  Created by Chinthan M on 26/05/25.
//

import Foundation
import Combine
import AudioKit
import AVFoundation
import SwiftUI

/// A manager that handles audio input, amplitude analysis, beat detection, and color mapping.
///
final class AudioManager: AudioManagerProtocol {

    // MARK: - Audio Engine & Taps

    private let engine = AudioEngine()
    private var amplitudeTap: AmplitudeTap?

    // MARK: - Subjects & Publishers

    private let amplitudeSubject = PassthroughSubject<Float, Never>()
    private let beatDetectedSubject = PassthroughSubject<Void, Never>()
    private let dominantColorSubject = PassthroughSubject<Color, Never>()

    public var amplitudePublisher: AnyPublisher<Float, Never> {
        amplitudeSubject.eraseToAnyPublisher()
    }

    public var beatDetectedPublisher: AnyPublisher<Void, Never> {
        beatDetectedSubject.eraseToAnyPublisher()
    }

    public var dominantColorPublisher: AnyPublisher<Color, Never> {
        dominantColorSubject.eraseToAnyPublisher()
    }

    // MARK: - State

    private var amplitudeHistory: [Float] = []
    private var hasPermission = false
    private var lastBeatTime: TimeInterval = 0
    private let beatCooldown: TimeInterval = 0.3

    // MARK: - Microphone Permission

    /// Requests microphone permission from the user.
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        #if os(macOS)
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
                completion(granted)
            }
        }
        #else
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                self.hasPermission = granted
                completion(granted)
            }
        }
        #endif
    }

    // MARK: - Engine Control

    /// Starts the audio engine and amplitude analysis.
    func start() {
        guard hasPermission else {
            print("AudioManager -> Microphone permission not granted.")
            return
        }

        guard let input = engine.input else {
            print("AudioManager -> No audio input available.")
            return
        }

        configureAudioSession()
        setupAmplitudeTap(for: input)
        configureEngineWithInput(input)
    }

    /// Pauses the audio engine.
    func pause() {
        stopAmplitudeTapIfNeeded()
        engine.pause()
        print("AudioManager -> Audio Engine paused.")
    }

    /// Resumes the audio engine and amplitude analysis.
    func resume() {
        guard let input = engine.input else {
            print("AudioManager -> No audio input available to resume.")
            return
        }

        setupAmplitudeTap(for: input)
        do {
            try engine.start()
            print("AudioManager -> Audio Engine resumed.")
        } catch {
            print("AudioManager -> Failed to resume AudioKit engine: \(error.localizedDescription)")
        }
    }

    /// Stops the audio engine and analysis.
    func stop() {
        stopAmplitudeTapIfNeeded()
        engine.stop()
        engine.output = nil
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        #endif
        print("AudioManager -> Audio Engine stopped.")
    }

    // MARK: - Configuration

    private func configureAudioSession() {
        #if !os(macOS)
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    private func configureEngineWithInput(_ input: Node) {
        let mixer = Mixer(input)
        engine.output = mixer
        do {
            try engine.start()
            print("AudioManager -> Audio Engine started.")
        } catch {
            print("AudioManager -> Failed to start AudioKit engine: \(error.localizedDescription)")
        }
    }

    // MARK: - Amplitude Handling

    private func setupAmplitudeTap(for input: Node) {
        stopAmplitudeTapIfNeeded()
        amplitudeTap = AmplitudeTap(input) { [weak self] amplitude in
            self?.handleAmplitude(amplitude)
        }
        amplitudeTap?.start()
        print("AudioManager -> Amplitude tap started.")
    }

    private func stopAmplitudeTapIfNeeded() {
        amplitudeTap?.stop()
        amplitudeTap = nil
    }

    func handleAmplitude(_ amplitude: Float) {
        amplitudeSubject.send(amplitude)
        detectBeat(from: amplitude)
        dominantColorSubject.send(colorForAmplitude(amplitude))
    }

    // MARK: - Beat Detection

    private func detectBeat(from amplitude: Float) {
        amplitudeHistory.append(amplitude)
        if amplitudeHistory.count > 10 {
            amplitudeHistory.removeFirst()
        }

        let average = amplitudeHistory.reduce(0, +) / Float(amplitudeHistory.count)
        let currentTime = CACurrentMediaTime()
        let isBeat = amplitude > average * 1.5 && amplitude > 0.05

        if isBeat && (currentTime - lastBeatTime > beatCooldown) {
            lastBeatTime = currentTime
            beatDetectedSubject.send()
            print("AudioManager -> Beat Detected | Amp: \(amplitude) | Avg: \(average)")
        }
    }

    // MARK: - Color Mapping

    func colorForAmplitude(_ amplitude: Float) -> Color {
        switch amplitude {
        case 0..<0.1: return .pink.opacity(0.7)
        case 0.1..<0.3: return .orange
        case 0.3..<0.5: return .yellow
        default: return .red
        }
    }
}
