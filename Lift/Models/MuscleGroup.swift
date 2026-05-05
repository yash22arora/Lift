// MuscleGroup.swift
// Lift — Muscle Group Enumeration

import Foundation

enum MuscleGroup: String, Codable, CaseIterable, Identifiable, Sendable {
    case chest       = "Chest"
    case back        = "Back"
    case shoulders   = "Shoulders"
    case biceps      = "Biceps"
    case triceps     = "Triceps"
    case legs        = "Legs"
    case glutes      = "Glutes"
    case core        = "Core"
    case fullBody    = "Full Body"
    case cardio      = "Cardio"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .chest:     return "figure.strengthtraining.traditional"
        case .back:      return "arrow.backward.circle"
        case .shoulders: return "arrow.up.circle"
        case .biceps:    return "figure.arms.open"
        case .triceps:   return "hand.raised"
        case .legs:      return "figure.walk"
        case .glutes:    return "figure.run"
        case .core:      return "circle.hexagongrid"
        case .fullBody:  return "figure.mixed.cardio"
        case .cardio:    return "heart.circle"
        }
    }
}

enum ExerciseCategory: String, Codable, CaseIterable, Sendable {
    case barbell    = "Barbell"
    case dumbbell   = "Dumbbell"
    case machine    = "Machine"
    case cable      = "Cable"
    case bodyweight = "Bodyweight"
    case cardio     = "Cardio"
    case other      = "Other"
}
