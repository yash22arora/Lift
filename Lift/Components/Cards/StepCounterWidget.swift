// StepCounterWidget.swift
// Lift — 80px step count widget for Dashboard (synced from HealthKit)

import SwiftUI

struct StepCounterWidget: View {
    let steps: Int
    let goal: Int
    let isError: Bool
    let isLoading: Bool

    init(steps: Int = 0, goal: Int = 10_000, isError: Bool = false, isLoading: Bool = false) {
        self.steps = steps
        self.goal = goal
        self.isError = isError
        self.isLoading = isLoading
    }

    private var progress: Double {
        Double(steps) / Double(goal)
    }

    private var stepsFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(isError ? Color.liftAccent : Color.liftPrimary)
                    Text("STEPS TODAY")
                        .liftCaptionStyle(color: isError ? .liftAccent : .liftMuted)
                }
                Spacer()
                if isError {
                    Text("SYNC FAILED")
                        .liftCaptionStyle(color: .liftAccent)
                }
            }

            if isLoading {
                // Skeleton
                Rectangle()
                    .fill(Color.liftSurfaceElevated)
                    .frame(width: 100, height: 24)
            } else {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(stepsFormatted)
                        .font(.liftDataLg)
                        .foregroundStyle(isError ? Color.liftAccent : Color.liftText)
                        .monospacedDigit()
                    Text("/ 10K")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            }

            NeonProgressBar(
                value: progress,
                height: 4,
                color: isError ? .liftAccent : .liftPrimary
            )
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: ComponentSize.stepWidgetHeight)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(
                    isError ? Color.liftAccent : Color.liftBorder,
                    lineWidth: isError ? BorderWidth.thick : BorderWidth.thin
                )
        )
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        StepCounterWidget(steps: 8_432)
        StepCounterWidget(steps: 0, isError: true)
        StepCounterWidget(isLoading: true)
    }
    .padding()
    .background(Color.liftBackground)
}
