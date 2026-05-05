// RestTimerLiveActivity.swift
// Lift Live Activity Extension — Dynamic Island + Lock Screen UI
//
// ⚠️  DO NOT add this file to the main "Lift" app target.
//     It belongs exclusively in the WidgetKit Extension target.
//     When you create the extension in Xcode, move this file there
//     and create a separate entry-point file for the bundle:
//
//     @main
//     struct LiftLiveActivityBundle: WidgetBundle {
//         var body: some Widget { RestTimerLiveActivity() }
//     }

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: — Live Activity Widget

struct RestTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RestTimerAttributes.self) { context in
            // Lock Screen / Banner UI
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("REST")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
                            .tracking(1)
                        Text(context.state.exerciseName.uppercased())
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date()...context.state.restEndTime, countsDown: true)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
                        .multilineTextAlignment(.trailing)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ProgressView(
                        timerInterval: Date()...context.state.restEndTime,
                        countsDown: true,
                        label: { EmptyView() },
                        currentValueLabel: { EmptyView() }
                    )
                    .progressViewStyle(.linear)
                    .tint(Color(red: 0.8, green: 1.0, blue: 0))
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
            } compactTrailing: {
                Text(timerInterval: Date()...context.state.restEndTime, countsDown: true)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
                    .frame(width: 36)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
            }
            .widgetURL(URL(string: "lift://active-workout"))
            .keylineTint(Color(red: 0.8, green: 1.0, blue: 0))
        }
    }

    @ViewBuilder
    private func lockScreenView(context: ActivityViewContext<RestTimerAttributes>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.workoutName.uppercased())
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                Text("REST · \(context.state.exerciseName.uppercased())")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
            }
            Spacer()
            Text(timerInterval: Date()...context.state.restEndTime, countsDown: true)
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(red: 0.8, green: 1.0, blue: 0))
        }
        .padding()
        .background(Color.black)
    }
}
