// ContentView.swift
// Lift — Root navigation with native TabView

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("TRAIN", systemImage: "figure.strengthtraining.traditional")
            }

            NavigationStack {
                PlaceholderTabView(title: "WORKOUT LOG", subtitle: "Coming soon")
            }
            .tabItem {
                Label("LOG", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                ProgressionView()
            }
            .tabItem {
                Label("STATS", systemImage: "chart.bar.fill")
            }

            NavigationStack {
                PlaceholderTabView(title: "ELITE", subtitle: "Profile & settings")
            }
            .tabItem {
                Label("ELITE", systemImage: "person.fill")
            }
        }
        .tint(Color.liftPrimary)
    }
}

// MARK: — Placeholder tab

struct PlaceholderTabView: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()
            VStack(spacing: Spacing.sm) {
                Text(title)
                    .font(.liftHeadingMd)
                    .foregroundStyle(Color.liftText)
                Text(subtitle)
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
                    .tracking(0.6)
                    .textCase(.uppercase)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [Workout.self, WorkoutExercise.self, WorkoutSet.self],
            inMemory: true
        )
}
