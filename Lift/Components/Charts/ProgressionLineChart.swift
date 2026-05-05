// ProgressionLineChart.swift
// Lift — Custom neon line chart with hard angular points and drag-to-scrub tooltip

import SwiftUI

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ProgressionLineChart: View {
    let dataPoints: [ChartDataPoint]
    let yLabel: String
    let isEmpty: Bool

    @State private var selectedIndex: Int? = nil
    @State private var tooltipPosition: CGPoint = .zero
    @GestureState private var dragLocation: CGPoint? = nil

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                if isEmpty || dataPoints.count < 2 {
                    emptyState
                } else {
                    chartContent(size: geo.size)
                }
            }
        }
        .frame(height: 240)
    }

    // MARK: — Chart content

    @ViewBuilder
    private func chartContent(size: CGSize) -> some View {
        let points = normalizedPoints(in: size)

        ZStack(alignment: .topLeading) {
            // Grid lines
            gridLines(size: size)

            // Line path
            Path { path in
                guard let first = points.first else { return }
                path.move(to: first)
                for pt in points.dropFirst() {
                    path.addLine(to: pt)
                }
            }
            .stroke(Color.liftPrimary, lineWidth: 2)
            .shadow(color: .liftPrimary.opacity(0.5), radius: 6)

            // Area fill
            Path { path in
                guard let first = points.first else { return }
                path.move(to: CGPoint(x: first.x, y: size.height))
                path.addLine(to: first)
                for pt in points.dropFirst() {
                    path.addLine(to: pt)
                }
                path.addLine(to: CGPoint(x: points.last!.x, y: size.height))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.liftPrimary.opacity(0.15), Color.liftPrimary.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Data point dots
            ForEach(Array(points.enumerated()), id: \.offset) { index, pt in
                Circle()
                    .fill(selectedIndex == index ? Color.liftPrimary : Color.liftBackground)
                    .frame(width: selectedIndex == index ? 10 : 6, height: selectedIndex == index ? 10 : 6)
                    .overlay(
                        Circle().stroke(Color.liftPrimary, lineWidth: 2)
                    )
                    .position(pt)
                    .animation(.liftFast, value: selectedIndex)
            }

            // Tooltip
            if let idx = selectedIndex, idx < dataPoints.count {
                ChartTooltip(
                    dataPoint: dataPoints[idx],
                    yLabel: yLabel
                )
                .position(tooltipPosition)
                .animation(.liftFast, value: selectedIndex)
            }

            // Drag gesture overlay
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            updateSelection(at: value.location, points: points, size: size)
                        }
                        .onEnded { _ in
                            selectedIndex = nil
                        }
                )
        }
    }

    // MARK: — Grid

    private func gridLines(size: CGSize) -> some View {
        let steps = 4
        return ZStack(alignment: .topLeading) {
            ForEach(0..<steps, id: \.self) { i in
                let y = size.height / CGFloat(steps) * CGFloat(i)
                Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                .stroke(Color.liftBorder, lineWidth: 0.5)
            }
        }
    }

    // MARK: — Empty state

    private var emptyState: some View {
        ZStack {
            // Ghost chart visual
            Path { path in
                path.move(to: CGPoint(x: 0, y: 160))
                path.addLine(to: CGPoint(x: 80, y: 120))
                path.addLine(to: CGPoint(x: 160, y: 140))
                path.addLine(to: CGPoint(x: 240, y: 80))
                path.addLine(to: CGPoint(x: 320, y: 60))
            }
            .stroke(Color.liftBorder, lineWidth: 2)

            VStack(spacing: Spacing.sm) {
                Text("INSUFFICIENT DATA")
                    .font(.liftButton)
                    .foregroundStyle(Color.liftMuted)
                Text("Log more workouts to see trends")
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftBorder)
            }
        }
    }

    // MARK: — Helpers

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard dataPoints.count >= 2 else { return [] }
        let minVal = dataPoints.map(\.value).min() ?? 0
        let maxVal = dataPoints.map(\.value).max() ?? 1
        let range = maxVal - minVal == 0 ? 1 : maxVal - minVal
        let minDate = dataPoints.map(\.date).min()!.timeIntervalSince1970
        let maxDate = dataPoints.map(\.date).max()!.timeIntervalSince1970
        let dateRange = maxDate - minDate == 0 ? 1 : maxDate - minDate
        let padding: CGFloat = 20

        return dataPoints.map { dp in
            let x = padding + CGFloat((dp.date.timeIntervalSince1970 - minDate) / dateRange) * (size.width - padding * 2)
            let y = size.height - padding - CGFloat((dp.value - minVal) / range) * (size.height - padding * 2)
            return CGPoint(x: x, y: y)
        }
    }

    private func updateSelection(at location: CGPoint, points: [CGPoint], size: CGSize) {
        guard !points.isEmpty else { return }
        let closest = points.enumerated().min(by: { abs($0.element.x - location.x) < abs($1.element.x - location.x) })
        guard let (idx, pt) = closest else { return }
        if selectedIndex != idx {
            selectedIndex = idx
            HapticService.selectionChanged()
        }
        // Keep tooltip inside bounds
        let tipX = min(max(pt.x, 60), size.width - 60)
        let tipY = max(pt.y - 40, 30)
        tooltipPosition = CGPoint(x: tipX, y: tipY)
    }
}
