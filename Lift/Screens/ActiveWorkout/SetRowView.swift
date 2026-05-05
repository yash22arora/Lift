// SetRowView.swift
// Lift — Set row matching the design — active set has neon left border

import SwiftUI

struct SetRowView: View {
    let set: WorkoutSet
    let exercise: WorkoutExercise
    let isActive: Bool
    let onComplete: () -> Void
    let onDelete: () -> Void

    @State private var weightText: String
    @State private var repsText: String
    @State private var isFlashing: Bool = false

    init(set: WorkoutSet, exercise: WorkoutExercise, isActive: Bool, onComplete: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.set = set
        self.exercise = exercise
        self.isActive = isActive
        self.onComplete = onComplete
        self.onDelete = onDelete
        _weightText = State(initialValue: set.weightLbs > 0 ? String(format: "%.0f", set.weightLbs) : "")
        _repsText   = State(initialValue: set.reps > 0 ? "\(set.reps)" : "")
    }

    var body: some View {
        HStack(spacing: 0) {
            // Neon left border for active set
            if isActive {
                Rectangle()
                    .fill(Color.liftPrimary)
                    .frame(width: 3)
            }

            HStack(spacing: 0) {
                // Set number
                Text("\(set.setNumber)")
                    .font(.liftDataMd)
                    .foregroundStyle(isActive ? Color.liftPrimary : (set.isCompleted ? Color.liftMuted : Color.liftText))
                    .frame(width: 50, alignment: .leading)
                    .monospacedDigit()

                // Weight
                TextField("0", text: $weightText)
                    .font(.liftDataMd)
                    .foregroundStyle(set.isCompleted ? Color.liftMuted : Color.liftText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .disabled(set.isCompleted)
                    .monospacedDigit()

                // Reps
                TextField("0", text: $repsText)
                    .font(.liftDataMd)
                    .foregroundStyle(set.isCompleted ? Color.liftMuted : Color.liftText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .disabled(set.isCompleted)
                    .monospacedDigit()

                // Checkbox
                Button {
                    handleComplete()
                } label: {
                    ZStack {
                        Rectangle()
                            .fill(set.isCompleted ? Color.liftPrimary : Color.clear)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Rectangle()
                                    .stroke(set.isCompleted ? Color.liftPrimary : Color.liftBorder, lineWidth: 1.5)
                            )

                        if set.isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Color.liftBackground)
                        }
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 44)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, 12)
        }
        .background(
            isFlashing ? Color.liftPrimary.opacity(0.15) :
            isActive ? Color.liftSurface.opacity(0.5) :
            Color.liftSurface
        )
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(
                    isActive ? Color.liftPrimary.opacity(0.3) : Color.liftBorder,
                    lineWidth: BorderWidth.thin
                )
        )
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 3)
        .animation(.liftFast, value: isFlashing)
        .animation(.liftFast, value: set.isCompleted)
        .onChange(of: weightText) { _, new in
            if let v = Double(new) { set.weightLbs = v }
        }
        .onChange(of: repsText) { _, new in
            if let v = Int(new) { set.reps = v }
        }
    }

    private func handleComplete() {
        guard !set.isCompleted else { return }
        // Commit values
        if let w = Double(weightText) { set.weightLbs = w }
        if let r = Int(repsText)      { set.reps = r }
        // Flash
        withAnimation(.liftFast) { isFlashing = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.liftFast) { self.isFlashing = false }
        }
        onComplete()
    }
}
