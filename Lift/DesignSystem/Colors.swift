// Colors.swift
// Lift Design System — Color Tokens
// All colors defined as static Color extensions for type-safe, autocomplete-friendly usage.

import SwiftUI

extension Color {

    // MARK: — Core Palette

    /// Neon Lime: Primary CTAs, active states, progress fills
    static let liftPrimary = Color(hex: "#CCFF00")

    /// True Obsidian: App background, absolute depth
    static let liftBackground = Color(hex: "#050505")

    /// Card Surface: Cards, input fields, modal backgrounds
    static let liftSurface = Color(hex: "#141414")

    /// Elevated Surface: Dropdowns, FABs, overlays
    static let liftSurfaceElevated = Color(hex: "#242424")

    /// Off-White Text: Primary readable text
    static let liftText = Color(hex: "#F5F5F5")

    /// Muted: Secondary text, inactive states, subtle borders
    static let liftMuted = Color(hex: "#666666")

    /// Neon Pink: Destructive actions — delete set, cancel workout
    static let liftAccent = Color(hex: "#FF2E93")

    /// Border: 1px hairline borders between elements
    static let liftBorder = Color(hex: "#333333")

    // MARK: — Semantic Aliases

    /// Alias: success / completion state (same as primary)
    static let liftSuccess = Color.liftPrimary

    /// Alias: error / destructive (same as accent)
    static let liftError = Color.liftAccent
}

// MARK: — Hex Initialiser

extension Color {
    /// Initialises a Color from a CSS hex string (e.g. "#CCFF00" or "CCFF00").
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
