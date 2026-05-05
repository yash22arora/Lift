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
    var alreadyAddedExercises: Set<String> = []  // exercises already in the workout
    var isLoading: Bool = false

    private let repo = ExerciseRepository.shared

    // MARK: — Computed

    var filteredExercises: [ExerciseDefinition] {
        repo.search(query: searchQuery, muscleGroup: selectedMuscleGroup)
    }

    /// Only count newly selected exercises (not already-added ones)
    var newlySelectedCount: Int {
        selectedExercises.subtracting(alreadyAddedExercises).count
    }

    var addButtonTitle: String {
        newlySelectedCount == 0 ? "SELECT EXERCISES" : "ADD \(newlySelectedCount) EXERCISE\(newlySelectedCount == 1 ? "" : "S")"
    }

    var canAdd: Bool { newlySelectedCount > 0 }

    /// Only return newly selected definitions (exclude already-added)
    var selectedDefinitions: [ExerciseDefinition] {
        let newIds = selectedExercises.subtracting(alreadyAddedExercises)
        return repo.exercises.filter { newIds.contains($0.id) }
    }

    // MARK: — Actions

    func toggleSelection(_ definition: ExerciseDefinition) {
        // Don't allow toggling off already-added exercises
        if alreadyAddedExercises.contains(definition.id) {
            return
        }
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
        selectedExercises = alreadyAddedExercises
    }

    /// Pre-populate with already-added exercise IDs
    func setAlreadyAdded(_ ids: Set<String>) {
        alreadyAddedExercises = ids
        selectedExercises = selectedExercises.union(ids)
    }

    func reset() {
        searchQuery = ""
        selectedMuscleGroup = nil
        selectedExercises.removeAll()
        alreadyAddedExercises.removeAll()
    }
}
