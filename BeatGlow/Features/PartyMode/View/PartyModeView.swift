//
//  PartyMode.swift
//  BeatGlow
//
//  Created by Chinthan M on 26/05/25.
//

import SwiftUI
import AVFoundation

/// Displays a music visualizer that reacts to microphone input.
struct PartyModeView: View {
    // MARK: - State

    @StateObject private var viewModel = PartyModeViewModel()
    @State private var isMicrophoneDenied = false

    // MARK: - View

    var body: some View {
        ZStack {
            backgroundView
            beatGlowTitle
            outerPulseCircle
            beatIndicatorCircle
            amplitudeIndicatorCircle
            controlButton
        }
        .onAppear {
            viewModel.checkMicrophonePermissionAndStart()
        }
        .onDisappear {
            viewModel.stop()
        }
        .alert(isPresented: $isMicrophoneDenied) {
            Alert(
                title: Text("Microphone Access Denied"),
                message: Text("Please enable microphone access to use the visualizer."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Subviews

    private var backgroundView: some View {
        viewModel.dominantColor
            .opacity(0.8)
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.2), value: viewModel.dominantColor)
    }

    private var beatGlowTitle: some View {
        VStack {
            Text("BeatGlow")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.purple)
                .scaleEffect(viewModel.isBeatDetected ? 1.3 : 1.0)
                .shadow(
                    color: .white.opacity(0.8),
                    radius: viewModel.isBeatDetected ? 20 : 5
                )
                .padding(.top, 60)
                .animation(.easeOut(duration: 0.15), value: viewModel.isBeatDetected)
                .accessibilityIdentifier("titleText")
            Spacer()
        }
    }

    private var outerPulseCircle: some View {
        Circle()
            .stroke(viewModel.dominantColor, lineWidth: 5)
            .frame(
                width: CGFloat(100 + viewModel.amplitude * 150),
                height: CGFloat(100 + viewModel.amplitude * 150)
            )
            .opacity(viewModel.isBeatDetected ? 0.8 : 0.6)
            .animation(
                viewModel.isRunning
                    ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                    : .default,
                value: viewModel.isRunning ? viewModel.isBeatDetected : false
            )
    }

    private var beatIndicatorCircle: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 180, height: 180)
            .scaleEffect(viewModel.isBeatDetected ? 1.6 : 1.0)
            .opacity(viewModel.isBeatDetected ? 0.9 : 0.7)
            .shadow(
                color: .red,
                radius: viewModel.isBeatDetected ? 40 : 15
            )
            .animation(.easeOut(duration: 0.15), value: viewModel.isBeatDetected)
            .accessibilityIdentifier("beatIndicatorCircle")
    }

    private var amplitudeIndicatorCircle: some View {
        Circle()
            .fill(Color.purple)
            .frame(
                width: CGFloat(50 + viewModel.amplitude * 150),
                height: CGFloat(50 + viewModel.amplitude * 150)
            )
            .shadow(
                color: Color.white.opacity(0.5),
                radius: viewModel.isBeatDetected ? 20 : 10
            )
            .animation(.easeOut(duration: 0.1), value: viewModel.amplitude)
            .accessibilityIdentifier("amplitudeIndicatorCircle")
    }

    private var controlButton: some View {
        VStack {
            Spacer()
            Button(action: {
                viewModel.toggleVisualizer()
            }, label: {
                Text(viewModel.isRunning ? "Stop" : "Start")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(viewModel.isRunning ? Color.red : Color.indigo)
                    )
                    .shadow(color: Color.red.opacity(0.6), radius: 10, x: 0, y: 5)
                    .accessibilityIdentifier("controlButton")
            })
            .padding(.bottom, 40)
            .scaleEffect(viewModel.isRunning ? 1.1 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: viewModel.isRunning)

            #if os(macOS)
            .buttonStyle(PlainButtonStyle())
            #endif
        }
    }
}
