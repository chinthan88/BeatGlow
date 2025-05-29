//
//  MockAudioManager.swift
//  BeatGlow
//
//  Created by Chinthan M on 28/05/25.
//

import Combine
import SwiftUI

class MockAudioManager: AudioManagerProtocol {
    var amplitudeSubject = PassthroughSubject<Float, Never>()
    var beatSubject = PassthroughSubject<Void, Never>()
    var colorSubject = PassthroughSubject<Color, Never>()

    var amplitudePublisher: AnyPublisher<Float, Never> {
        amplitudeSubject.eraseToAnyPublisher()
    }
    var beatDetectedPublisher: AnyPublisher<Void, Never> {
        beatSubject.eraseToAnyPublisher()
    }
    var dominantColorPublisher: AnyPublisher<Color, Never> {
        colorSubject.eraseToAnyPublisher()
    }

    var startCalled = false
    var stopCalled = false
    var pauseCalled = false
    var resumeCalled = false
    var microphonePermissionResult: Bool = true

    func start() { startCalled = true }
    func stop() { stopCalled = true }
    func pause() { pauseCalled = true }
    func resume() { resumeCalled = true }
    func toggleVisualizer() { resumeCalled = true }

    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        completion(microphonePermissionResult)
    }
}
