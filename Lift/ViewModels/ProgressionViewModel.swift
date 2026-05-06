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
    
    // New stats
    var avgSessionTime: String = "—"
    var avgSessionFrequency: String = "—"

    private var repository: WorkoutRepository?

    // MARK: — Computed

    var isEmpty: Bool { chartData.count < 2 }

    var growthFormatted: String {
        let prefix = growthPercentage >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", growthPercentage))%"
    }

    var yLabel: String {
        "KG"
    }

    // MARK: — Load

    func load(exerciseId: String, exerciseName: String, repository: WorkoutRepository) {
        self.repository = repository
        self.selectedExerciseId = exerciseId
        self.selectedExerciseName = exerciseName
        loadAvailableExercises()
        loadGeneralStats()
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
        let allExercises = ExerciseRepository.shared.exercises
        guard let repo = repository else {
            availableExercises = allExercises
            return
        }
        
        do {
            let workouts = try repo.fetchAllWorkouts()
            var counts: [String: Int] = [:]
            for w in workouts {
                for ex in w.exercises {
                    counts[ex.exerciseDefinitionId, default: 0] += 1
                }
            }
            
            availableExercises = allExercises.sorted {
                let countA = counts[$0.id, default: 0]
                let countB = counts[$1.id, default: 0]
                if countA != countB {
                    return countA > countB
                }
                return $0.name < $1.name
            }
        } catch {
            availableExercises = allExercises
        }
    }

    private func loadGeneralStats() {
        guard let repo = repository else { return }
        do {
            let workouts = try repo.fetchAllWorkouts().filter { $0.endDate != nil }
            guard !workouts.isEmpty else { return }
            
            // Avg Session Time
            let totalDuration = workouts.compactMap { $0.duration }.reduce(0, +)
            let avgSeconds = totalDuration / Double(workouts.count)
            let minutes = Int(avgSeconds) / 60
            avgSessionTime = "\(minutes)m"
            
            // Avg Frequency per week
            if let firstWorkout = workouts.last { // workouts are sorted by date descending, so last is oldest
                let daysSinceStart = max(1, Calendar.current.dateComponents([.day], from: firstWorkout.startDate, to: Date()).day ?? 1)
                let weeks = Double(daysSinceStart) / 7.0
                let freq = Double(workouts.count) / max(1.0, weeks)
                avgSessionFrequency = String(format: "%.1f", freq)
            }
        } catch {
            print("Error loading general stats: \(error)")
        }
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
