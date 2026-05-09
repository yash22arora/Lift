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

    // Real step data via HealthKit
    var stepCount: Int = 0
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
        do {
            try await HealthKitService.shared.requestAuthorization()
            stepCount = await HealthKitService.shared.todayStepCount()
        } catch {
            print("[Dashboard] HealthKit authorization error: \(error)")
        }
        
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
