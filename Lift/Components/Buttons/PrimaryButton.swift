// PrimaryButton.swift
// Lift — Full-width neon lime CTA button

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let height: CGFloat
    let isLoading: Bool
    let action: () -> Void

    init(
        _ title: String,
        icon: String? = nil,
        height: CGFloat = ComponentSize.ctaHeight,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.height = height
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.liftBackground)
                        .scaleEffect(0.8)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color.liftBackground)
                    }
                    Text(title)
                        .font(.liftButton)
                        .foregroundStyle(Color.liftBackground)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.liftPrimary)
            .cornerRadius(Radius.none)
        }
        .buttonStyle(LiftButtonStyle(haptic: .medium))
        .disabled(isLoading)
    }
}

// MARK: — Preview

#Preview {
    VStack(spacing: Spacing.md) {
        PrimaryButton("START WORKOUT", icon: "bolt.fill") {}
        PrimaryButton("LOADING", isLoading: true) {}
    }
    .padding()
    .background(Color.liftBackground)
}
