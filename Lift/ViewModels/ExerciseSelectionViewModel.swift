// ExerciseSelectionViewModel.swift
// Lift — State and filtering for exercise selection modal

import Foundation
import Observation

@Observable
@MainActor
final class ExerciseSelectionViewModel {

    // MARK: — State

    var searchQuery: String = ""
    var selectedMuscleGroup: MuscleGroup? = nil
    var selectedExercises: Set<String> = []  // exercise definition IDs
    var isLoading: Bool = false

    private let repo = ExerciseRepository.shared

    // MARK: — Computed

    var filteredExercises: [ExerciseDefinition] {
        repo.search(query: searchQuery, muscleGroup: selectedMuscleGroup)
    }

    var selectedCount: Int { selectedExercises.count }

    var addButtonTitle: String {
        selectedCount == 0 ? "SELECT EXERCISES" : "ADD \(selectedCount) EXERCISE\(selectedCount == 1 ? "" : "S")"
    }

    var canAdd: Bool { selectedCount > 0 }

    var selectedDefinitions: [ExerciseDefinition] {
        repo.exercises.filter { selectedExercises.contains($0.id) }
    }

    // MARK: — Actions

    func toggleSelection(_ definition: ExerciseDefinition) {
        if selectedExercises.contains(definition.id) {
            selectedExercises.remove(definition.id)
        } else {
            selectedExercises.insert(definition.id)
        }
        HapticService.selectionChanged()
    }

    func isSelected(_ definition: ExerciseDefinition) -> Bool {
        selectedExercises.contains(definition.id)
    }

    func clearSelection() {
        selectedExercises.removeAll()
    }

    func reset() {
        searchQuery = ""
        selectedMuscleGroup = nil
        selectedExercises.removeAll()
    }
}
