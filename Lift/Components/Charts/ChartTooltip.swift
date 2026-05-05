// ChartTooltip.swift
// Lift — Tooltip shown when scrubbing the progression chart

import SwiftUI

struct ChartTooltip: View {
    let dataPoint: ChartDataPoint
    let yLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(dataPoint.date.formatted(date: .abbreviated, time: .omitted))
                .font(.liftCaptionXS)
                .foregroundStyle(Color.liftBackground.opacity(0.7))
                .textCase(.uppercase)
                .tracking(0.4)

            Text(formattedValue)
                .font(.liftDataSm)
                .foregroundStyle(Color.liftBackground)
                .monospacedDigit()
        }
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, 6)
        .background(Color.liftPrimary)
        .cornerRadius(Radius.sm)
    }

    private var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        let val = formatter.string(from: NSNumber(value: dataPoint.value)) ?? "\(dataPoint.value)"
        return "\(val) \(yLabel)"
    }
}
