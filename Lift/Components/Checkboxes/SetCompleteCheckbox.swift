// SetCompleteCheckbox.swift
// Lift — 32x32 square checkbox for marking a set as complete

import SwiftUI

struct SetCompleteCheckbox: View {
    @Binding var isChecked: Bool
    let onComplete: () -> Void

    var body: some View {
        Button {
            withAnimation(.liftFast) {
                isChecked.toggle()
            }
            if isChecked { onComplete() }
        } label: {
            ZStack {
                // Background
                Rectangle()
                    .fill(isChecked ? Color.liftPrimary : Color.liftSurfaceElevated)
                    .frame(width: ComponentSize.checkboxSize, height: ComponentSize.checkboxSize)
                    .cornerRadius(Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(
                                isChecked ? Color.liftPrimary : Color.liftBorder,
                                lineWidth: BorderWidth.thin
                            )
                    )

                // Checkmark
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.liftBackground)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.liftFast, value: isChecked)
    }
}

// MARK: — Multi-select variant (24x24, for exercise selection list)

struct MultiSelectCheckbox: View {
    @Binding var isSelected: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? Color.liftPrimary : Color.clear)
                .frame(width: ComponentSize.multiCheckSize, height: ComponentSize.multiCheckSize)
                .cornerRadius(Radius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(
                            isSelected ? Color.liftPrimary : Color.liftMuted,
                            lineWidth: BorderWidth.thin
                        )
                )

            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.liftBackground)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.liftFast, value: isSelected)
        .allowsHitTesting(false) // Parent row handles tap
    }
}

#Preview {
    HStack(spacing: Spacing.xl) {
        SetCompleteCheckbox(isChecked: .constant(false)) {}
        SetCompleteCheckbox(isChecked: .constant(true)) {}
        MultiSelectCheckbox(isSelected: .constant(false))
        MultiSelectCheckbox(isSelected: .constant(true))
    }
    .padding()
    .background(Color.liftBackground)
}
