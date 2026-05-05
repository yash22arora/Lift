// ExerciseRepository.swift
// Lift — Loads, caches, and filters the bundled exercise library

import Foundation

@MainActor
final class ExerciseRepository {

    static let shared = ExerciseRepository()

    private(set) var exercises: [ExerciseDefinition] = []

    private init() {
        exercises = loadLibrary()
    }

    // MARK: — Load

    private func loadLibrary() -> [ExerciseDefinition] {
        guard let url = Bundle.main.url(forResource: "ExerciseLibrary", withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            print("[ExerciseRepository] Failed to load ExerciseLibrary.json")
            return []
        }
        do {
            return try JSONDecoder().decode([ExerciseDefinition].self, from: data)
        } catch {
            print("[ExerciseRepository] Decode error: \(error)")
            return []
        }
    }

    // MARK: — Filter

    func search(query: String, muscleGroup: MuscleGroup? = nil, category: ExerciseCategory? = nil) -> [ExerciseDefinition] {
        exercises.filter { exercise in
            let matchesQuery = query.isEmpty ||
                exercise.name.localizedCaseInsensitiveContains(query)
            let matchesMuscle = muscleGroup == nil ||
                exercise.muscleGroups.contains(muscleGroup!)
            let matchesCategory = category == nil ||
                exercise.category == category
            return matchesQuery && matchesMuscle && matchesCategory
        }
        .sorted { $0.name < $1.name }
    }

    func exercise(for id: String) -> ExerciseDefinition? {
        exercises.first { $0.id == id }
    }
}
