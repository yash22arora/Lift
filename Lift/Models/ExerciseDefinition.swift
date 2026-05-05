// ExerciseDefinition.swift
// Lift — Static Exercise Library Entry (Codable, not SwiftData)

import Foundation

struct ExerciseDefinition: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let muscleGroups: [MuscleGroup]
    let category: ExerciseCategory
    let instructions: String?

    init(
        id: String,
        name: String,
        muscleGroups: [MuscleGroup],
        category: ExerciseCategory,
        instructions: String? = nil
    ) {
        self.id = id
        self.name = name
        self.muscleGroups = muscleGroups
        self.category = category
        self.instructions = instructions
    }
}
