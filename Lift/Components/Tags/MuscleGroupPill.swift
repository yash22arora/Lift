// MuscleGroupPill.swift
// Lift — Horizontal scroll filter pill for muscle group selection

import SwiftUI

struct MuscleGroupPill: View {
    let group: MuscleGroup
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(group.rawValue.uppercased())
                    .font(.liftCaption)
                    .tracking(0.6)
                    .foregroundStyle(isSelected ? Color.liftBackground : Color.liftText)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Radius.pill)
                    .fill(isSelected ? Color.liftPrimary : Color.liftSurfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Radius.pill)
                    .stroke(
                        isSelected ? Color.clear : Color.liftBorder,
                        lineWidth: BorderWidth.thin
                    )
            )
        }
        .buttonStyle(LiftButtonStyle(haptic: .light))
        .animation(.liftFast, value: isSelected)
    }
}

// MARK: — Pill scroll bar

struct MuscleGroupPillBar: View {
    @Binding var selected: MuscleGroup?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.sm) {
                // "ALL" pill
                Button {
                    withAnimation(.liftFast) { selected = nil }
                    HapticService.lightImpact()
                } label: {
                    Text("ALL")
                        .font(.liftCaption)
                        .tracking(0.6)
                        .foregroundStyle(selected == nil ? Color.liftBackground : Color.liftText)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: Radius.pill)
                                .fill(selected == nil ? Color.liftPrimary : Color.liftSurfaceElevated)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Radius.pill)
                                .stroke(
                                    selected == nil ? Color.clear : Color.liftBorder,
                                    lineWidth: BorderWidth.thin
                                )
                        )
                }
                .buttonStyle(.plain)

                ForEach(MuscleGroup.allCases) { group in
                    MuscleGroupPill(
                        group: group,
                        isSelected: selected == group
                    ) {
                        withAnimation(.liftFast) {
                            selected = selected == group ? nil : group
                        }
                        HapticService.lightImpact()
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        MuscleGroupPill(group: .chest, isSelected: true) {}
        MuscleGroupPill(group: .back, isSelected: false) {}
        MuscleGroupPillBar(selected: .constant(.chest))
    }
    .background(Color.liftBackground)
}
