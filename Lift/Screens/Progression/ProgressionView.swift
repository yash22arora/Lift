// ProgressionView.swift
// Lift — Progression analytics screen matching design mockups

import SwiftUI
import SwiftData

struct ProgressionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressionViewModel()
    @State private var showVolumeTooltip = false
    @State private var show1RMTooltip = false

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // ─── Stats Overview ────────────────────────────────
                    statsOverview
                    
                    Divider().tint(.liftPrimary)

                    // ─── Exercise Header (Dropdown) ────────────────────
                    exerciseHeader

                    // ─── Metric Segmented Control ──────────────────────
                    metricSegmentedControl

                    // ─── KPI Stats ─────────────────────────────────────
                    kpiStats

                    // ─── Chart ─────────────────────────────────────────
                    chartSection

                    // ─── Session History ───────────────────────────────
                    sessionHistory
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Progression")
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            let repo = WorkoutRepository(modelContext: modelContext)
            viewModel.load(
                exerciseId: "barbell_bench_press",
                exerciseName: "Barbell Bench Press",
                repository: repo
            )
        }
    }

    // MARK: — Stats Overview

    private var statsOverview: some View {
        HStack(spacing: Spacing.md) {
            statBox(label: "AVG SESSION TIME", value: viewModel.avgSessionTime)
            statBox(label: "SESSIONS / WEEK", value: viewModel.avgSessionFrequency)
        }
        .padding(.vertical, 12)
    }

    private func statBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .liftCaptionStyle()
            Text(value)
                .font(.liftDataMd)
                .foregroundStyle(Color.liftPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.md)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
        )
    }

    // MARK: — Exercise Header (Dropdown)

    private var exerciseHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("CURRENT EXERCISE")
                .liftCaptionStyle()
            
            Menu {
                ForEach(viewModel.availableExercises) { def in
                    Button {
                        viewModel.selectExercise(def)
                    } label: {
                        HStack {
                            Text(def.name.uppercased())
                            if def.id == viewModel.selectedExerciseId {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.selectedExerciseName.uppercased())
                        .font(.liftHeadingMd)
                        .foregroundStyle(Color.liftText)
                        .minimumScaleFactor(0.6)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.liftPrimary)
                }
                .padding(.vertical, 8)
                .cornerRadius(Radius.sm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: — Segmented Control (VOLUME | 1RM with tooltips)

    private var metricSegmentedControl: some View {
        HStack(spacing: 0) {
            ForEach(ProgressionMetric.allCases, id: \.rawValue) { metric in
                Button {
                    viewModel.switchMetric(to: metric)
                } label: {
                    VStack(spacing: 0) {
                        HStack(spacing: 4) {
                            Text(metric.rawValue)
                                .font(.liftBodyMd)
                            
                            Image(systemName: "info.circle")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.liftMuted)
                                .onTapGesture {
                                    if metric == .volume { showVolumeTooltip = true }
                                    else { show1RMTooltip = true }
                                }
                                .popover(isPresented: metric == .volume ? $showVolumeTooltip : $show1RMTooltip) {
                                    tooltipContent(for: metric)
                                        .presentationCompactAdaptation(.popover)
                                }
                        }
                        .foregroundStyle(
                            viewModel.selectedMetric == metric
                                ? Color.liftText
                                : Color.liftMuted
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: ComponentSize.segmentHeight)

                        // Active underline
                        Rectangle()
                            .fill(viewModel.selectedMetric == metric ? Color.liftPrimary : Color.liftBorder)
                            .frame(height: viewModel.selectedMetric == metric ? 2 : 1)
                    }
                }
                .buttonStyle(.plain)
                .animation(.liftFast, value: viewModel.selectedMetric)
            }
        }
    }

    private func tooltipContent(for metric: ProgressionMetric) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(metric.rawValue)
                .font(.liftHeadingMd)
                .foregroundStyle(Color.liftPrimary)
            
            Text(metric == .volume ? 
                 "Total weight moved during your workout. Calculated as: Weight × Reps × Sets." :
                 "The maximum amount of weight you can lift for a single repetition, estimated using the Epley formula.")
                .font(.liftBodyMd)
                .foregroundStyle(Color.liftText)
        }
        .padding()
        .frame(width: 280)
        .background(Color.liftSurface)
    }

    // MARK: — KPI Stats

    private var kpiStats: some View {
        HStack(spacing: 0) {
            // Current 1RM or max volume
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.selectedMetric == .oneRM ? "CURRENT 1RM ESTIMATE" : "MAX VOLUME")
                    .liftCaptionStyle()

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(kpiMainValue)
                        .font(.liftDataXL)
                        .foregroundStyle(Color.liftPrimary)
                        .monospacedDigit()
                    Text("KG")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            }

            Spacer()

            // 30 Day Trend
            if !viewModel.isEmpty {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("30 DAY TREND")
                        .liftCaptionStyle()

                    HStack(spacing: 4) {
                        Image(systemName: viewModel.growthPercentage >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .bold))
                        Text(viewModel.growthFormatted)
                            .font(.liftCaption)
                            .tracking(0.4)
                            .monospacedDigit()
                    }
                    .foregroundStyle(viewModel.growthPercentage >= 0 ? Color.liftPrimary : Color.liftAccent)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(
                                viewModel.growthPercentage >= 0 ? Color.liftPrimary : Color.liftAccent,
                                lineWidth: BorderWidth.thin
                            )
                    )
                }
            }
        }
    }

    private var kpiMainValue: String {
        if viewModel.chartData.isEmpty { return "—" }
        let val = viewModel.chartData.last?.value ?? 0
        return String(format: "%.0f", val)
    }

    // MARK: — Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            ProgressionLineChart(
                dataPoints: viewModel.chartData,
                yLabel: viewModel.yLabel,
                isEmpty: viewModel.isEmpty
            )
            .frame(height: 220)
            .padding(Spacing.sm)
            .background(Color.liftSurface)
            .cornerRadius(Radius.sm)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
            )
        }
    }

    // MARK: — Session History

    private var sessionHistory: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("SESSION HISTORY")
                    .liftCaptionStyle()
                Spacer()
                Text("LAST 30 DAYS")
                    .liftCaptionStyle()
            }

            if viewModel.chartData.isEmpty {
                Text("No sessions yet for this exercise.")
                    .font(.liftBody)
                    .foregroundStyle(Color.liftMuted)
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.liftSurface)
                    .cornerRadius(Radius.sm)
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(viewModel.chartData.reversed().prefix(10).enumerated()), id: \.offset) { _, point in
                        sessionHistoryRow(point: point)
                    }
                }
            }
        }
    }

    private func sessionHistoryRow(point: ChartDataPoint) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(point.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.liftBodyMd)
                    .foregroundStyle(Color.liftText)
                Text("— SETS • — REPS")
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f", point.value))
                    .font(.liftDataMd)
                    .foregroundStyle(Color.liftPrimary)
                    .monospacedDigit()
                Text("EST. 1RM")
                    .liftCaptionStyle()
            }
        }
        .padding(Spacing.md)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
        )
    }

}
