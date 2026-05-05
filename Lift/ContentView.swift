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
                LogsView()
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
                ProfileView()
            }
            .tabItem {
                Label("PROFILE", systemImage: "person.fill")
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
