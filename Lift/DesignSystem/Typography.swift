// Typography.swift
// Lift Design System — Typography Tokens
// Custom font helpers. Fonts must be registered in Info.plist.
// Add BebasNeue-Regular.ttf and SpaceGrotesk-*.ttf to Lift/Resources/Fonts/

import SwiftUI

// MARK: — Font Name Constants

enum LiftFontName {
    static let bebasNeue     = "BebasNeue-Regular"
    static let spaceGroteskRegular = "SpaceGrotesk-Regular"
    static let spaceGroteskMedium  = "SpaceGrotesk-Medium"
    static let spaceGroteskBold    = "SpaceGrotesk-Bold"
}

// MARK: — Font Tokens

extension Font {

    // ─── Display / Headings (Bebas Neue) ───────────────────────────────────

    /// 48px — Primary screen titles e.g. "TRAIN TODAY"
    static let liftHeadingXL = Font.custom(LiftFontName.bebasNeue, size: 48)

    /// 40px — Section headings
    static let liftHeadingLg = Font.custom(LiftFontName.bebasNeue, size: 40)

    /// 32px — Card / modal headings
    static let liftHeadingMd = Font.custom(LiftFontName.bebasNeue, size: 32)

    /// 24px — Button labels, sub-headings
    static let liftButton    = Font.custom(LiftFontName.bebasNeue, size: 24)

    // ─── Body (Space Grotesk) ──────────────────────────────────────────────

    /// 16px Regular — Standard body copy
    static let liftBody      = Font.custom(LiftFontName.spaceGroteskRegular, size: 16)

    /// 16px Medium — Slightly emphasised body
    static let liftBodyMd    = Font.custom(LiftFontName.spaceGroteskMedium, size: 16)

    // ─── Data Points (Space Grotesk Bold) ─────────────────────────────────

    /// 32px Bold — Big KPI numbers (progression percentage)
    static let liftDataXL    = Font.custom(LiftFontName.spaceGroteskBold, size: 32)

    /// 28px Bold — Large data values
    static let liftDataLg    = Font.custom(LiftFontName.spaceGroteskBold, size: 28)

    /// 20px Bold — Card stats, timers
    static let liftDataMd    = Font.custom(LiftFontName.spaceGroteskBold, size: 20)

    /// 16px Bold — Inline data labels
    static let liftDataSm    = Font.custom(LiftFontName.spaceGroteskBold, size: 16)

    // ─── Small / Caption (Space Grotesk Medium) ────────────────────────────

    /// 12px Medium — Labels, tags, metadata
    static let liftCaption   = Font.custom(LiftFontName.spaceGroteskMedium, size: 12)

    /// 11px Medium — Very small labels
    static let liftCaptionXS = Font.custom(LiftFontName.spaceGroteskMedium, size: 11)
}

// MARK: — View Modifier Helpers

extension View {

    /// Applies Lift caption style: 12px medium, uppercase, wide tracking
    func liftCaptionStyle(color: Color = .liftMuted) -> some View {
        self
            .font(.liftCaption)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .tracking(0.8)
    }

    /// Applies tabular lining numbers for numeric displays
    func liftTabularNums() -> some View {
        self.monospacedDigit()
    }
}
