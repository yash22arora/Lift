// Animation.swift
// Lift Design System — Animation & Haptic Presets

import SwiftUI

// MARK: — Animation Tokens

extension Animation {

    /// Fast spring — primary micro-interaction (stiffness: 400, damping: 25)
    static let liftFast = Animation.spring(
        response: 0.25,
        dampingFraction: 0.65,
        blendDuration: 0
    )

    /// Standard spring — sheet presentations, view transitions
    static let liftSpring = Animation.spring(
        response: 0.35,
        dampingFraction: 0.72,
        blendDuration: 0
    )

    /// Smooth spring — content updates, progress bars
    static let liftSmooth = Animation.spring(
        response: 0.45,
        dampingFraction: 0.85,
        blendDuration: 0
    )

    /// Instant — segmented control tab swap (no crossfade)
    static let liftInstant = Animation.linear(duration: 0)
}

// MARK: — Scale Button Style

/// Applies 0.97 scale-down on press with haptic feedback
struct LiftButtonStyle: ButtonStyle {
    var haptic: UIImpactFeedbackGenerator.FeedbackStyle = .medium

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.liftFast, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    let generator = UIImpactFeedbackGenerator(style: haptic)
                    generator.impactOccurred()
                }
            }
    }
}

/// Soft press style for list rows
struct LiftRowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.liftSurfaceElevated : Color.clear)
            .animation(.liftFast, value: configuration.isPressed)
    }
}
