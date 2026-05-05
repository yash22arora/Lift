// NeonProgressBar.swift
// Lift — Linear progress bar with neon lime fill

import SwiftUI

struct NeonProgressBar: View {
    let value: Double      // 0.0 – 1.0
    let height: CGFloat
    let color: Color
    let trackColor: Color
    let showGlow: Bool

    init(
        value: Double,
        height: CGFloat = 6,
        color: Color = .liftPrimary,
        trackColor: Color = .liftSurface,
        showGlow: Bool = true
    ) {
        self.value = max(0, min(1, value))
        self.height = height
        self.color = color
        self.trackColor = trackColor
        self.showGlow = showGlow
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Track
                Rectangle()
                    .fill(trackColor)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(0)

                // Fill
                Rectangle()
                    .fill(color)
                    .frame(width: geo.size.width * value)
                    .cornerRadius(0)
                    .shadow(
                        color: showGlow ? color.opacity(0.6) : .clear,
                        radius: 4, x: 0, y: 0
                    )
                    .animation(.liftSmooth, value: value)
            }
        }
        .frame(height: height)
    }
}

// MARK: — Labelled version for dashboard widgets

struct LabelledProgressBar: View {
    let label: String
    let value: Double
    let current: String
    let target: String
    let isError: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(label)
                    .liftCaptionStyle()
                Spacer()
                HStack(spacing: 4) {
                    Text(current)
                        .font(.liftDataSm)
                        .foregroundStyle(isError ? Color.liftAccent : Color.liftText)
                        .monospacedDigit()
                    Text("/ \(target)")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            }
            NeonProgressBar(
                value: value,
                color: isError ? .liftAccent : .liftPrimary
            )
        }
    }
}

#Preview {
    VStack(spacing: Spacing.lg) {
        NeonProgressBar(value: 0.75)
        NeonProgressBar(value: 0.4, color: .liftAccent)
        LabelledProgressBar(
            label: "Steps",
            value: 0.84,
            current: "8,432",
            target: "10K",
            isError: false
        )
    }
    .padding()
    .background(Color.liftBackground)
}
