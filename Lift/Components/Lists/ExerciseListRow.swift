// ExerciseListRow.swift
// Lift — Dense 56px exercise row with multi-select checkbox

import SwiftUI

struct ExerciseListRow: View {
    let definition: ExerciseDefinition
    let isSelected: Bool
    let recentWeight: Double?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.md) {
                MultiSelectCheckbox(isSelected: .constant(isSelected))

                VStack(alignment: .leading, spacing: 3) {
                    Text(definition.name)
                        .font(.liftBodyMd)
                        .foregroundStyle(isSelected ? Color.liftPrimary : Color.liftText)
                        .lineLimit(1)

                    Text(definition.muscleGroups.map(\.rawValue).joined(separator: " · ").uppercased())
                        .liftCaptionStyle()
                        .lineLimit(1)
                }

                Spacer()

                if let weight = recentWeight, weight > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f", weight))
                            .font(.liftDataSm)
                            .foregroundStyle(Color.liftMuted)
                            .monospacedDigit()
                        Text("KG")
                            .liftCaptionStyle()
                    }
                }
            }
            .padding(.horizontal, Spacing.md)
            .frame(height: ComponentSize.listRowHeight)
            .background(isSelected ? Color.liftPrimary.opacity(0.06) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.liftFast, value: isSelected)
    }
}

// MARK: — Skeleton

struct ExerciseListRowSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        HStack(spacing: Spacing.md) {
            RoundedRectangle(cornerRadius: Radius.sm)
                .fill(Color.liftSurfaceElevated)
                .frame(width: ComponentSize.multiCheckSize, height: ComponentSize.multiCheckSize)

            VStack(alignment: .leading, spacing: 6) {
                Rectangle()
                    .fill(shimmerColor)
                    .frame(width: 160, height: 14)
                Rectangle()
                    .fill(Color.liftSurface)
                    .frame(width: 100, height: 10)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.md)
        .frame(height: ComponentSize.listRowHeight)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                shimmer = true
            }
        }
    }

    private var shimmerColor: Color {
        shimmer ? Color.liftSurfaceElevated : Color.liftSurface
    }
}
