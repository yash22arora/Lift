// GlassmorphismHeader.swift
// Lift — Blurred glassmorphism sticky header that activates on scroll

import SwiftUI

struct GlassmorphismHeader<Content: View>: View {
    let content: () -> Content
    var isBlurred: Bool = true

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .background {
                if isBlurred {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .background(Color.liftBackground.opacity(0.7))
                        .ignoresSafeArea(edges: .top)
                } else {
                    Color.liftBackground
                        .ignoresSafeArea(edges: .top)
                }
            }
            .animation(.liftSmooth, value: isBlurred)
    }
}

// MARK: — Scroll offset tracker (for activating blur on scroll)

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollOffsetReader: View {
    var body: some View {
        GeometryReader { geo in
            Color.clear
                .preference(
                    key: ScrollOffsetKey.self,
                    value: geo.frame(in: .named("scroll")).minY
                )
        }
        .frame(height: 0)
    }
}
