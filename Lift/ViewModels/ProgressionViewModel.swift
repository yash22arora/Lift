// ProgressionViewModel.swift
// Lift — Analytics state for volume and 1RM charts

import Foundation
import SwiftData
import Observation

enum ProgressionMetric: String, CaseIterable {
    case volume = "VOLUME"
    case oneRM  = "1RM"
}

@Observable
@MainActor
final class ProgressionViewModel {

    // MARK: — State

    var selectedMetric: ProgressionMetric = .volume
    var selectedExerciseId: String = ""
    var selectedExerciseName: String = "Barbell Bench Press"
    var chartData: [ChartDataPoint] = []
    var isLoading: Bool = false
    var isError: Bool = false
    var growthPercentage: Double = 0
    var availableExercises: [ExerciseDefinition] = []

    private var repository: WorkoutRepository?

    // MARK: — Computed

    var isEmpty: Bool { chartData.count < 2 }

    var growthFormatted: String {
        let prefix = growthPercentage >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", growthPercentage))%"
    }

    var yLabel: String {
        selectedMetric == .volume ? "LBS" : "LBS"
    }

    // MARK: — Load

    func load(exerciseId: String, exerciseName: String, repository: WorkoutRepository) {
        self.repository = repository
        self.selectedExerciseId = exerciseId
        self.selectedExerciseName = exerciseName
        loadAvailableExercises()
        Task { await loadChartData() }
    }

    func switchMetric(to metric: ProgressionMetric) {
        selectedMetric = metric
        Task { await loadChartData() }
        HapticService.selectionChanged()
    }

    func selectExercise(_ def: ExerciseDefinition) {
        selectedExerciseId = def.id
        selectedExerciseName = def.name
        Task { await loadChartData() }
    }

    // MARK: — Private

    private func loadAvailableExercises() {
        availableExercises = ExerciseRepository.shared.exercises
    }

    private func loadChartData() async {
        guard let repo = repository, !selectedExerciseId.isEmpty else { return }
        isLoading = true
        isError = false
        do {
            let workoutExercises = try repo.fetchWorkoutsForExercise(exerciseDefinitionId: selectedExerciseId)
            chartData = workoutExercises.compactMap { ex -> ChartDataPoint? in
                guard let value = metricValue(for: ex) else { return nil }
                // Use the parent workout's date — we grab it via the context relationship
                return ChartDataPoint(date: Date(), value: value)
            }
            .sorted { $0.date < $1.date }

            computeGrowth()
        } catch {
            isError = true
        }
        isLoading = false
    }

    private func metricValue(for exercise: WorkoutExercise) -> Double? {
        switch selectedMetric {
        case .volume:
            let v = exercise.totalVolume
            return v > 0 ? v : nil
        case .oneRM:
            return exercise.bestEstimated1RM
        }
    }

    private func computeGrowth() {
        guard chartData.count >= 2 else { growthPercentage = 0; return }
        let first = chartData.first!.value
        let last  = chartData.last!.value
        guard first > 0 else { growthPercentage = 0; return }
        growthPercentage = ((last - first) / first) * 100
    }
}
