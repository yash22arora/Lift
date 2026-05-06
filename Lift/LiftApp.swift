// LiftApp.swift
// Lift — App entry point with SwiftData container

import SwiftUI
import SwiftData

@main
struct LiftApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Workout.self,
            WorkoutExercise.self,
            WorkoutSet.self,
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("[Lift] Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
