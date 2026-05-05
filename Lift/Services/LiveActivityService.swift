// LiveActivityService.swift
// Lift — DEFERRED: Live Activity integration disabled for now.
// Keeping file as placeholder for future WidgetKit extension.

import Foundation

@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()
    private init() {}

    func startRestTimer(workoutName: String, exerciseName: String, setNumber: Int, restDurationSeconds: TimeInterval = 90) {
        // No-op: Live Activity deferred
    }

    func stopRestTimer() {
        // No-op: Live Activity deferred
    }
}
