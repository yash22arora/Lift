// Spacing.swift
// Lift Design System — Spacing & Layout Tokens

import CoreFoundation

enum Spacing {
    static let xs:  CGFloat = 4
    static let sm:  CGFloat = 8
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 24
    static let xl:  CGFloat = 32
    static let xxl: CGFloat = 48
    static let xxxl: CGFloat = 64
}

enum Radius {
    /// 0px — Sharp corners everywhere (brutalist aesthetic)
    static let sm:   CGFloat = 0
    /// 0px
    static let md:   CGFloat = 0
    /// 0px — Tags and pills are also sharp
    static let pill: CGFloat = 0
    /// 0px
    static let none: CGFloat = 0
}

enum BorderWidth {
    static let hairline: CGFloat = 0.5
    static let thin:     CGFloat = 1
    static let thick:    CGFloat = 2
}

enum ComponentSize {
    /// Quick-start CTA height
    static let ctaHeight:        CGFloat = 64
    /// Standard input field height
    static let inputHeight:      CGFloat = 48
    /// Search bar height
    static let searchBarHeight:  CGFloat = 56
    /// Exercise list row height
    static let listRowHeight:    CGFloat = 56
    /// Recent session card height
    static let sessionCardHeight: CGFloat = 120
    /// Step counter widget height
    static let stepWidgetHeight:  CGFloat = 80
    /// Set complete checkbox size
    static let checkboxSize:      CGFloat = 32
    /// Multi-select checkbox size
    static let multiCheckSize:    CGFloat = 24
    /// Segmented control height
    static let segmentHeight:     CGFloat = 40
    /// Bottom safe area padding buffer
    static let bottomSafeBuffer:  CGFloat = 32
}
