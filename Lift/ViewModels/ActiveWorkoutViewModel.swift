// ActiveWorkoutViewModel.swift
// Lift — Active workout state (no LiveActivity, core logging only)

import Foundation
import SwiftData
import SwiftUI

@Observable
@MainActor
final class ActiveWorkoutViewModel {

    // MARK: — State

    var workout: Workout?
    var elapsedSeconds: Int = 0
    var showRestTimer: Bool = false
    var restTimerExerciseName: String = ""
    var restTimerSetNumber: Int = 0
    var showExerciseSelection: Bool = false
    var isFinishing: Bool = false
    var currentExerciseIndex: Int = 0
    var hasStarted: Bool = false

    private var repository: WorkoutRepository?
    nonisolated(unsafe) private var timerTask: Task<Void, Never>?

    // MARK: — Computed

    var elapsedFormatted: String {
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    var sortedExercises: [WorkoutExercise] {
        workout?.sortedExercises ?? []
    }

    var currentExercise: WorkoutExercise? {
        let exercises = sortedExercises
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }

    var nextExercise: WorkoutExercise? {
        let exercises = sortedExercises
        let nextIdx = currentExerciseIndex + 1
        guard nextIdx < exercises.count else { return nil }
        return exercises[nextIdx]
    }

    // MARK: — Lifecycle

    /// Initialize the workout with selected exercises and start the timer
    func startWorkout(name: String = "Quick Workout", repository: WorkoutRepository, initialExercises: [ExerciseDefinition]) {
        self.repository = repository
        let w = repository.createWorkout(name: name)
        self.workout = w
        // Add initial exercises
        for def in initialExercises {
            let ex = repository.addExercise(to: w, definition: def)
            _ = repository.addSet(to: ex)
        }
        repository.save()
        hasStarted = true
        startTimer()
        HapticService.heavyImpact()
    }

    /// IDs of exercises already added to the current workout
    var alreadyAddedExerciseIds: Set<String> {
        Set(sortedExercises.map { $0.exerciseDefinitionId })
    }

    func finishWorkout() {
        guard let workout, let repo = repository else { return }
        isFinishing = true
        repo.finishWorkout(workout)
        repo.save()
        stopTimer()
        HapticService.success()
    }

    // MARK: — Timer

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                elapsedSeconds += 1
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    // MARK: — Exercise Navigation

    func goToNextExercise() {
        let max = sortedExercises.count - 1
        if currentExerciseIndex < max {
            currentExerciseIndex += 1
            HapticService.impact(.medium)
        }
    }

    func goToPreviousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            HapticService.impact(.medium)
        }
    }

    // MARK: — Exercise Management

    func addExercises(_ definitions: [ExerciseDefinition]) {
        guard let workout, let repo = repository else { return }
        for def in definitions {
            let ex = repo.addExercise(to: workout, definition: def)
            _ = repo.addSet(to: ex)
        }
        repo.save()
        HapticService.impact(.medium)
    }

    func addSet(to exercise: WorkoutExercise) {
        guard let repo = repository else { return }
        _ = repo.addSet(to: exercise)
        repo.save()
        HapticService.lightImpact()
    }

    func completeSet(_ set: WorkoutSet, exercise: WorkoutExercise) {
        guard let repo = repository else { return }
        repo.completeSet(set)
        repo.save()
        HapticService.rigidImpact()

        // Trigger rest timer
        restTimerExerciseName = exercise.exerciseName
        restTimerSetNumber = set.setNumber
        showRestTimer = true

        // Auto-add next set row if this was the last one
        if exercise.sortedSets.last?.id == set.id {
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                addSet(to: exercise)
            }
        }
    }

    func deleteSet(_ set: WorkoutSet, from exercise: WorkoutExercise) {
        guard let repo = repository else { return }
        repo.deleteSet(set, from: exercise)
        repo.save()
        HapticService.impact(.medium)
    }

    func deleteExercise(_ exercise: WorkoutExercise) {
        guard let workout, let repo = repository else { return }
        repo.deleteExercise(exercise, from: workout)
        repo.save()
        // Adjust index if needed
        if currentExerciseIndex >= sortedExercises.count && currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
        }
    }

    deinit {
        timerTask?.cancel()
    }
}
