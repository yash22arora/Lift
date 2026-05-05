// WorkoutSet.swift
// Lift — SwiftData model representing a single logged set

import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var setNumber: Int
    var weightLbs: Double
    var reps: Int
    var isCompleted: Bool
    var completedAt: Date?
    var rpe: Double?            // Rate of perceived exertion, optional

    init(
        setNumber: Int,
        weightLbs: Double = 0,
        reps: Int = 0,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.setNumber = setNumber
        self.weightLbs = weightLbs
        self.reps = reps
        self.isCompleted = isCompleted
    }

    /// Epley formula one-rep max estimate
    var estimatedOneRepMax: Double? {
        guard isCompleted, reps > 0, weightLbs > 0 else { return nil }
        if reps == 1 { return weightLbs }
        return weightLbs * (1 + Double(reps) / 30.0)
    }

    /// Volume contribution of this set
    var volume: Double {
        guard isCompleted else { return 0 }
        return weightLbs * Double(reps)
    }
}
