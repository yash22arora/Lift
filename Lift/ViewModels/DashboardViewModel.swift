// DashboardViewModel.swift
// Lift — Dashboard state (no HealthKit, mock data)

import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: — State

    var recentWorkouts: [Workout] = []
    var weeklyWorkoutCount: Int = 4
    var isLoadingWorkouts: Bool = false

    // Mock step data (static, no HealthKit)
    let stepCount: Int = 8_432
    let stepGoal: Int = 10_000

    private var repository: WorkoutRepository?

    // MARK: — Computed

    var stepProgress: Double {
        min(Double(stepCount) / Double(stepGoal), 1.0)
    }

    var stepsFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: stepCount)) ?? "\(stepCount)"
    }

    // MARK: — Load

    func load(repository: WorkoutRepository) {
        self.repository = repository
        Task { await loadWorkouts() }
    }

    func refresh() {
        Task { await loadWorkouts() }
    }

    private func loadWorkouts() async {
        guard let repo = repository else { return }
        isLoadingWorkouts = true
        do {
            recentWorkouts = try repo.fetchRecentWorkouts(limit: 2)
            weeklyWorkoutCount = try repo.fetchWorkoutsThisWeek().count
        } catch {
            print("[Dashboard] Workout fetch error: \(error)")
        }
        isLoadingWorkouts = false
    }
}
