// ExerciseSelectionView.swift
// Lift — Exercise selection modal matching the design mockups

import SwiftUI

struct ExerciseSelectionView: View {
    let onAdd: ([ExerciseDefinition]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ExerciseSelectionViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.liftBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // ─── Search Bar ───────────────────────────────────────
                SearchBar(text: $viewModel.searchQuery, placeholder: "SEARCH MOVEMENTS")
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.sm)

                // ─── Muscle Group Pills (simplified: CHEST, BACK, LEGS, ARMS) ─
                simplifiedPillBar
                    .padding(.bottom, Spacing.sm)

                Divider().background(Color.liftBorder)

                // ─── Exercise List ────────────────────────────────────
                exerciseList
            }

            // ─── Sticky Add CTA ───────────────────────────────────────
            VStack(spacing: 0) {
                PrimaryButton(viewModel.addButtonTitle) {
                    guard viewModel.canAdd else { return }
                    onAdd(viewModel.selectedDefinitions)
                    viewModel.reset()
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.lg)
            }
            .background(Color.liftBackground)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.liftBackground)
    }

    // MARK: — Simplified pill bar (CHEST, BACK, LEGS, ARMS matching mockup)

    private var simplifiedPillBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                filterPill("CHEST", group: .chest)
                filterPill("BACK", group: .back)
                filterPill("LEGS", group: .legs)
                filterPill("ARMS", group: nil, matchesArms: true)
                filterPill("SHOULDERS", group: .shoulders)
                filterPill("CORE", group: .core)
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private func filterPill(_ label: String, group: MuscleGroup?, matchesArms: Bool = false) -> some View {
        let isSelected: Bool = {
            if matchesArms {
                return viewModel.selectedMuscleGroup == .biceps || viewModel.selectedMuscleGroup == .triceps
            }
            return viewModel.selectedMuscleGroup == group
        }()

        return Button {
            withAnimation(.liftFast) {
                if matchesArms {
                    viewModel.selectedMuscleGroup = viewModel.selectedMuscleGroup == .biceps ? nil : .biceps
                } else {
                    viewModel.selectedMuscleGroup = viewModel.selectedMuscleGroup == group ? nil : group
                }
            }
            HapticService.lightImpact()
        } label: {
            Text(label)
                .font(.liftCaption)
                .tracking(0.6)
                .foregroundStyle(isSelected ? Color.liftBackground : Color.liftText)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: Radius.pill)
                        .fill(isSelected ? Color.liftPrimary : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.pill)
                        .stroke(isSelected ? Color.clear : Color.liftBorder, lineWidth: BorderWidth.thin)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: — List

    @ViewBuilder
    private var exerciseList: some View {
        let results = viewModel.filteredExercises

        if results.isEmpty && !viewModel.searchQuery.isEmpty {
            VStack(spacing: Spacing.md) {
                Spacer()
                Text("NO MATCHES FOUND.")
                    .font(.liftButton)
                    .foregroundStyle(Color.liftMuted)
                Spacer()
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(results) { definition in
                        exerciseRow(definition)
                        Divider()
                            .background(Color.liftBorder)
                            .padding(.leading, Spacing.md)
                    }
                }
                .padding(.bottom, ComponentSize.ctaHeight + Spacing.xl)
            }
        }
    }

    // MARK: — Exercise Row (matching mockup: name + MAX: XX KG + checkbox)

    private func exerciseRow(_ definition: ExerciseDefinition) -> some View {
        let isSelected = viewModel.isSelected(definition)

        return Button {
            viewModel.toggleSelection(definition)
        } label: {
            HStack(spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(definition.name.uppercased())
                        .font(.liftBodyMd)
                        .foregroundStyle(isSelected ? Color.liftPrimary : Color.liftText)
                    Text("MAX: — KG")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                        .tracking(0.4)
                }

                Spacer()

                // Checkbox
                ZStack {
                    Rectangle()
                        .fill(isSelected ? Color.liftPrimary : Color.clear)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Rectangle()
                                .stroke(isSelected ? Color.liftPrimary : Color.liftMuted, lineWidth: 1.5)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.liftBackground)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.liftFast, value: isSelected)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
