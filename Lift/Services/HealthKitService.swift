// HealthKitService.swift
// Lift — DEFERRED: HealthKit integration disabled for now.
// Keeping file as placeholder for future provisioning.

import Foundation

// MARK: — Placeholder (no HealthKit dependency)

@MainActor
final class HealthKitService {
    static let shared = HealthKitService()
    private init() {}

    /// Returns mock step count (HealthKit integration deferred)
    func todayStepCount() async -> Int {
        return 8_432
    }
}
