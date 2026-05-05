// IconButton.swift
// Lift — Square icon-only button (e.g. finish workout, add set)

import SwiftUI

enum IconButtonVariant {
    case surface       // #242424 background
    case primary       // #CCFF00 background
    case ghost         // Transparent background, muted icon
}

struct IconButton: View {
    let icon: String
    let size: CGFloat
    let variant: IconButtonVariant
    let action: () -> Void

    init(
        icon: String,
        size: CGFloat = 44,
        variant: IconButtonVariant = .surface,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.variant = variant
        self.action = action
    }

    private var bgColor: Color {
        switch variant {
        case .surface: return .liftSurfaceElevated
        case .primary: return .liftPrimary
        case .ghost:   return .clear
        }
    }

    private var fgColor: Color {
        switch variant {
        case .surface: return .liftText
        case .primary: return .liftBackground
        case .ghost:   return .liftMuted
        }
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(fgColor)
                .frame(width: size, height: size)
                .background(bgColor)
                .cornerRadius(Radius.sm)
        }
        .buttonStyle(LiftButtonStyle(haptic: .light))
    }
}

#Preview {
    HStack(spacing: Spacing.md) {
        IconButton(icon: "plus", variant: .primary) {}
        IconButton(icon: "checkmark", variant: .surface) {}
        IconButton(icon: "xmark", variant: .ghost) {}
    }
    .padding()
    .background(Color.liftBackground)
}
