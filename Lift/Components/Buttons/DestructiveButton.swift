// DestructiveButton.swift
// Lift — Neon pink destructive action button (delete, cancel)

import SwiftUI

struct DestructiveButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                }
                Text(title)
                    .font(.liftCaption)
                    .tracking(0.8)
                    .textCase(.uppercase)
            }
            .foregroundStyle(Color.liftAccent)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.liftAccent.opacity(0.12))
            .cornerRadius(Radius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(Color.liftAccent.opacity(0.3), lineWidth: BorderWidth.thin)
            )
        }
        .buttonStyle(LiftButtonStyle(haptic: .rigid))
    }
}

// MARK: — Label-only inline destructive label (for swipe actions)

struct DestructiveLabel: View {
    let title: String

    var body: some View {
        ZStack {
            Color.liftAccent
            Text(title)
                .font(.liftCaption)
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(.white)
        }
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        DestructiveButton("DELETE SET", icon: "trash") {}
        DestructiveButton("CANCEL WORKOUT") {}
    }
    .padding()
    .background(Color.liftBackground)
}
