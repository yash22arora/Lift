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

    init() {
        print("─── ALL FONTS ───")
        
        for family in UIFont.familyNames.sorted() {
            print("FAMILY:", family)
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   FONT:", name)
            }
        }
        
        print("────────────────")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
