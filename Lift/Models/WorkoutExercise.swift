// WorkoutExercise.swift
// Lift — SwiftData model for an exercise within a workout session

import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    var id: UUID
    var exerciseDefinitionId: String
    var exerciseName: String
    var order: Int
    var workout: Workout?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise) var sets: [WorkoutSet]

    init(
        exerciseDefinitionId: String,
        exerciseName: String,
        order: Int = 0
    ) {
        self.id = UUID()
        self.exerciseDefinitionId = exerciseDefinitionId
        self.exerciseName = exerciseName
        self.order = order
        self.sets = []
    }

    /// Total volume (lbs) across all completed sets
    var totalVolume: Double {
        sets.reduce(0) { $0 + $1.volume }
    }

    /// Best estimated 1RM across all completed sets
    var bestEstimated1RM: Double? {
        sets.compactMap { $0.estimatedOneRepMax }.max()
    }

    /// Number of completed sets
    var completedSetCount: Int {
        sets.filter { $0.isCompleted }.count
    }

    /// Sorted sets by set number
    var sortedSets: [WorkoutSet] {
        sets.sorted { $0.setNumber < $1.setNumber }
    }
}
