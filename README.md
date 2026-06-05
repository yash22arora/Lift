# Lift

A modern, native iOS workout tracker built with **SwiftUI** and **SwiftData**. Lift is designed for lifters who want to log strength workouts quickly during a session and watch their progress over time, wrapped in a bold, brutalist "neon-on-obsidian" design language.

> Screenshots coming soon.

---

## Features

- **Quick Workout logging** — Start a session in one tap, add exercises from a bundled library, and log sets (weight × reps) with a fast, tactile UI.
- **Live session tracking** — A running session timer, current/next exercise navigation, and an automatic rest timer that appears after each completed set.
- **Set management** — Auto-numbered sets, auto-added next set row when you complete the last one, swipe-to-delete, and one-rep-max / volume computed per set.
- **Exercise library** — 50+ built-in exercises (barbell, dumbbell, machine, cable, bodyweight, cardio) tagged by muscle group, searchable and filterable.
- **Workout history (Logs)** — Browse past sessions with swipe actions to edit or delete, and drill into a detail view per workout.
- **Progression analytics (Stats)** — Track **Volume** and **estimated 1RM** over time per exercise via a line chart, with growth percentage, average session time, and weekly frequency. The exercise picker is sorted by how often you train each movement.
- **Daily steps via HealthKit** — The dashboard reads your real step count for the day and shows progress toward a 10,000-step goal.
- **Haptics throughout** — Centralized haptic feedback on set completion, navigation, and key actions.
- **Rest Timer Live Activity (scaffolded)** — A WidgetKit/ActivityKit extension for a Dynamic Island + Lock Screen rest timer is included but currently deferred (no-op in the app).
- **Metric units** — All weights are tracked in **KG**.

---

## Tech Stack

| Area | Technology |
|------|------------|
| UI | SwiftUI (dark mode only) |
| Persistence | SwiftData (`@Model`) |
| State | `@Observable` view models (Observation framework) |
| Health data | HealthKit (step count) |
| Live Activity | ActivityKit + WidgetKit (extension target) |
| Charts | Swift Charts |
| Language | Swift 5 |
| Min. deployment | iOS 26.2 |

---

## Architecture

Lift follows an **MVVM + Repository** pattern with a centralized design system. Data flows in one direction: SwiftData models are accessed through repositories, exposed to the UI by `@Observable` view models, and rendered by composable SwiftUI screens and components.

```
┌─────────────────────────────────────────────────────────┐
│  Screens (SwiftUI Views)                                  │
│  Dashboard · ActiveWorkout · Logs · Progression · Profile │
└───────────────┬───────────────────────────────────────────┘
                │ observes
┌───────────────▼───────────────────────────────────────────┐
│  ViewModels (@Observable, @MainActor)                      │
│  Dashboard · ActiveWorkout · Progression · ExerciseSel.    │
└───────────────┬───────────────────────────────────────────┘
                │ calls
┌───────────────▼───────────────────────────────────────────┐
│  Repositories                                              │
│  WorkoutRepository (SwiftData CRUD) · ExerciseRepository   │
└───────────────┬───────────────────────────────────────────┘
                │ reads/writes
┌───────────────▼───────────────────────────────────────────┐
│  Models (SwiftData @Model + Codable)                       │
│  Workout → WorkoutExercise → WorkoutSet · ExerciseDef.     │
└────────────────────────────────────────────────────────────┘

   Services (cross-cutting): HealthKitService · HapticService · LiveActivityService
```

### Layers

- **Models** (`Lift/Models/`)
  - `Workout` → `WorkoutExercise` → `WorkoutSet` form a cascading SwiftData relationship graph. A workout owns exercises; an exercise owns sets.
  - Computed properties live on the models themselves: `totalVolumeKg`, `durationFormatted`, `estimatedOneRepMax` (Epley formula), per-set `volume`, etc.
  - `ExerciseDefinition` / `MuscleGroup` / `ExerciseCategory` are plain `Codable` types (not persisted) representing the static exercise library.

- **Repositories** (`Lift/Repositories/`)
  - `WorkoutRepository` wraps a `ModelContext` and is the single entry point for all create/read/update/delete and persistence on workout data.
  - `ExerciseRepository` is a singleton that loads, caches, searches, and filters the bundled `ExerciseLibrary.json`.

- **ViewModels** (`Lift/ViewModels/`)
  - `@Observable` `@MainActor` classes holding screen state and orchestrating repository calls (e.g. `ActiveWorkoutViewModel` owns the session timer, rest-timer triggers, and exercise navigation).

- **Screens & Components** (`Lift/Screens/`, `Lift/Components/`)
  - Screens compose small, reusable components (buttons, cards, charts, inputs, pills, skeletons, overlays).

- **Services** (`Lift/Services/`)
  - `HealthKitService` — authorization + today's step count.
  - `HapticService` — typed wrappers around UIKit feedback generators (`@MainActor`).
  - `LiveActivityService` — currently a no-op placeholder for the deferred Live Activity feature.

- **Design System** (`Lift/DesignSystem/`)
  - Centralized tokens for **Colors** (neon lime `#CCFF00` on obsidian `#050505`, neon pink accent for destructive actions), **Typography** (Bebas Neue for display, Space Grotesk for body/data), **Spacing**, and **Animation**.
  - Note the brutalist aesthetic: `Radius` tokens are all `0` — sharp corners everywhere.

### App entry & navigation

- `LiftApp.swift` builds the shared SwiftData `ModelContainer` (registering `Workout`, `WorkoutExercise`, `WorkoutSet`) and forces dark mode.
- `ContentView.swift` is a 4-tab `TabView`: **TRAIN** (Dashboard), **LOG** (Logs), **STATS** (Progression), **PROFILE**.

---

## Project Structure

```
Lift/
├── LiftApp.swift              # @main entry, SwiftData container
├── ContentView.swift          # Root TabView navigation
├── Models/                    # SwiftData + Codable models
├── ViewModels/                # @Observable screen state
├── Repositories/              # Data access (SwiftData + JSON library)
├── Services/                  # HealthKit, Haptics, LiveActivity
├── Screens/                   # Dashboard, ActiveWorkout, Logs, Progression, Profile, ...
├── Components/                # Reusable UI (buttons, cards, charts, inputs, ...)
├── DesignSystem/              # Colors, Typography, Spacing, Animation tokens
├── Resources/                 # ExerciseLibrary.json, fonts, images
├── LiveActivity/              # Shared ActivityKit attributes
└── Info.plist / Lift.entitlements

LiftLiveActivity/              # WidgetKit extension (Dynamic Island + Lock Screen)
docs/                          # Implementation notes
```

---

## Getting Started

### Prerequisites

- **Xcode** with the iOS 26.2 SDK (the deployment target is iOS 26.2).
- A physical device or simulator running iOS 26.2+.
- An Apple Developer account is recommended (the app uses HealthKit and a Live Activity extension, which require entitlements/capabilities).

### Run the app

1. Clone the repository and open the project:
   ```bash
   git clone <repo-url>
   cd Lift
   open Lift.xcodeproj
   ```
2. Select the **Lift** scheme and a simulator or connected device.
3. Set your development team under **Signing & Capabilities** if building to a device.
4. Press **⌘R** to build and run.

> HealthKit step data will be empty on a fresh simulator — add some step samples in the Health app, or run on a device, to see the dashboard step widget populate. The app requests HealthKit read authorization on first load of the dashboard.

### Bundled data

The exercise catalog lives in [`Lift/Resources/ExerciseLibrary.json`](Lift/Resources/ExerciseLibrary.json). To add or edit exercises, update that file — each entry has an `id`, `name`, `muscleGroups`, and `category`.

---

## Notes & Roadmap

- **Live Activity** is scaffolded (`LiftLiveActivity/`, `LiveActivityService`) but disabled; wiring it up to the rest timer is a natural next step.
- **Progression chart dates** currently use the fetch time rather than each workout's actual date — a known simplification in `ProgressionViewModel`.
- All weights are in **KG** (the app was migrated away from LBS).

---

*Built by [@servatom / Yashvardhan Arora]. Bundle identifier: `com.servatom.Lift`.*
