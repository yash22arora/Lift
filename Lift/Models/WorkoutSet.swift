// WorkoutSet.swift
// Lift — SwiftData model representing a single logged set

import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var setNumber: Int
    var weightKg: Double
    var reps: Int
    var isCompleted: Bool
    var completedAt: Date?
    var rpe: Double?            // Rate of perceived exertion, optional
    var exercise: WorkoutExercise?

    init(
        setNumber: Int,
        weightKg: Double = 0,
        reps: Int = 0,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weightKg = weightKg
        self.reps = reps
        self.isCompleted = isCompleted
    }

    /// Epley formula one-rep max estimate
    var estimatedOneRepMax: Double? {
        guard isCompleted, reps > 0, weightKg > 0 else { return nil }
        if reps == 1 { return weightKg }
        return weightKg * (1 + Double(reps) / 30.0)
    }

    /// Volume contribution of this set
    var volume: Double {
        guard isCompleted else { return 0 }
        return weightKg * Double(reps)
    }
}
