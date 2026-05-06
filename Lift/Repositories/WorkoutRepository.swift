// WorkoutRepository.swift
// Lift — CRUD operations for Workout sessions via SwiftData

import Foundation
import SwiftData

@MainActor
final class WorkoutRepository {

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: — Create

    func createWorkout(name: String = "Quick Workout") -> Workout {
        let workout = Workout(name: name)
        modelContext.insert(workout)
        return workout
    }

    // MARK: — Read

    func fetchAllWorkouts() throws -> [Workout] {
        let descriptor = FetchDescriptor<Workout>(
            sortBy: [SortDescriptor(\Workout.startDate, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func fetchRecentWorkouts(limit: Int = 10) throws -> [Workout] {
        var descriptor = FetchDescriptor<Workout>(
            predicate: #Predicate { $0.endDate != nil },
            sortBy: [SortDescriptor(\Workout.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }

    func fetchWorkoutsThisWeek() throws -> [Workout] {
        let startOfWeek = Calendar.current.dateComponents(
            [.yearForWeekOfYear, .weekOfYear],
            from: Date()
        )
        let weekStart = Calendar.current.date(from: startOfWeek) ?? Date()
        return try modelContext.fetch(
            FetchDescriptor<Workout>(
                predicate: #Predicate { $0.startDate >= weekStart && $0.endDate != nil }
            )
        )
    }

    func fetchWorkoutsForExercise(exerciseDefinitionId: String) throws -> [WorkoutExercise] {
        let descriptor = FetchDescriptor<WorkoutExercise>(
            predicate: #Predicate { $0.exerciseDefinitionId == exerciseDefinitionId },
            sortBy: [SortDescriptor(\WorkoutExercise.exerciseName)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: — Update

    func addExercise(to workout: Workout, definition: ExerciseDefinition) -> WorkoutExercise {
        let order = workout.exercises.count
        let exercise = WorkoutExercise(
            exerciseDefinitionId: definition.id,
            exerciseName: definition.name,
            order: order
        )
        modelContext.insert(exercise)
        workout.exercises.append(exercise)
        return exercise
    }

    func addSet(to exercise: WorkoutExercise, weight: Double = 0, reps: Int = 0) -> WorkoutSet {
        let setNumber = exercise.sets.count + 1
        let workoutSet = WorkoutSet(setNumber: setNumber, weightKg: weight, reps: reps)
        modelContext.insert(workoutSet)
        exercise.sets.append(workoutSet)
        return workoutSet
    }

    func completeSet(_ set: WorkoutSet) {
        set.isCompleted = true
        set.completedAt = Date()
    }

    func finishWorkout(_ workout: Workout) {
        workout.endDate = Date()
    }

    // MARK: — Delete

    func deleteSet(_ set: WorkoutSet, from exercise: WorkoutExercise) {
        exercise.sets.removeAll { $0.id == set.id }
        modelContext.delete(set)
        // Re-number remaining sets
        exercise.sortedSets.enumerated().forEach { index, s in
            s.setNumber = index + 1
        }
    }

    func deleteExercise(_ exercise: WorkoutExercise, from workout: Workout) {
        workout.exercises.removeAll { $0.id == exercise.id }
        modelContext.delete(exercise)
    }

    func deleteWorkout(_ workout: Workout) {
        modelContext.delete(workout)
    }

    func clearAllData() {
        do {
            try modelContext.delete(model: Workout.self)
            try modelContext.delete(model: WorkoutExercise.self)
            try modelContext.delete(model: WorkoutSet.self)
            save()
        } catch {
            print("[WorkoutRepository] Clear data error: \(error)")
        }
    }

    // MARK: — Persistence

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("[WorkoutRepository] Save error: \(error)")
        }
    }
}
