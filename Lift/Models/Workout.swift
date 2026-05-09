// Workout.swift
// Lift — SwiftData model for a complete workout session

import Foundation
import SwiftData

private let volumeFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.maximumFractionDigits = 0
    return f
}()

@Model
final class Workout {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date?
    var notes: String?
    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.workout) var exercises: [WorkoutExercise]

    init(name: String = "Quick Workout") {
        self.id = UUID()
        self.name = name
        self.startDate = Date()
        self.exercises = []
    }

    // MARK: — Computed Properties

    /// Duration in seconds, nil if still active
    var duration: TimeInterval? {
        guard let endDate else { return nil }
        return endDate.timeIntervalSince(startDate)
    }

    /// Human-readable duration string e.g. "1h 23m"
    var durationFormatted: String? {
        guard let duration else { return nil }
        let h = Int(duration) / 3600
        let m = (Int(duration) % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }

    /// Total volume across all exercises
    var totalVolumeKg: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }

    var totalVolumeFormatted: String {
        let formatted = volumeFormatter.string(from: NSNumber(value: totalVolumeKg)) ?? "0"
        return "\(formatted) KG"
    }

    /// Total completed sets across all exercises
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.completedSetCount }
    }

    /// Sorted exercises by order
    var sortedExercises: [WorkoutExercise] {
        exercises.sorted { $0.order < $1.order }
    }

    var isActive: Bool { endDate == nil }
}
