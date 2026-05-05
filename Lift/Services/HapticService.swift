// HapticService.swift
// Lift — Centralised haptic feedback helpers

internal import UIKit

/// Sendable singleton for triggering haptic feedback.
/// Call from @MainActor contexts only (UIKit feedback generators are main-thread bound).
@MainActor
enum HapticService {

    // MARK: — Impact

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let g = UIImpactFeedbackGenerator(style: style)
        g.prepare()
        g.impactOccurred()
    }

    static func lightImpact()  { impact(.light) }
    static func heavyImpact()  { impact(.heavy) }
    static func rigidImpact()  { impact(.rigid) }
    static func softImpact()   { impact(.soft) }

    // MARK: — Notification

    static func success() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.success)
    }

    static func warning() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.warning)
    }

    static func error() {
        let g = UINotificationFeedbackGenerator()
        g.notificationOccurred(.error)
    }

    // MARK: — Selection

    static func selectionChanged() {
        let g = UISelectionFeedbackGenerator()
        g.selectionChanged()
    }
}
