// PastWorkoutsView.swift
// Lift — Full history of completed workouts

import SwiftUI
import SwiftData

struct PastWorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<Workout> { $0.endDate != nil },
        sort: \Workout.startDate,
        order: .reverse
    )
    private var workouts: [Workout]

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()

            if workouts.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(workouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                PastWorkoutCard(workout: workout)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("PAST WORKOUTS")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(workouts.count) SESSIONS")
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.liftMuted)
            Text("NO WORKOUTS YET")
                .font(.liftHeadingMd)
                .foregroundStyle(Color.liftMuted)
            Text("COMPLETE A SESSION TO SEE IT HERE")
                .font(.liftCaption)
                .foregroundStyle(Color.liftMuted.opacity(0.6))
        }
    }
}

// MARK: — Past Workout Card

struct PastWorkoutCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {

            // ── Header row ─────────────────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.name.uppercased())
                        .font(.liftBodyMd)
                        .foregroundStyle(Color.liftText)

                    Text(formattedDate)
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                        .tracking(0.4)
                }

                Spacer()

                // Duration badge
                if let dur = workout.durationFormatted {
                    Text(dur)
                        .font(.liftDataSm)
                        .foregroundStyle(Color.liftPrimary)
                        .monospacedDigit()
                }
            }

            // ── Exercise chips ──────────────────────────────────────
            if !workout.sortedExercises.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(workout.sortedExercises) { ex in
                        let completedSets = ex.sets.filter { $0.isCompleted }
                        if !completedSets.isEmpty {
                            HStack(spacing: 6) {
                                Rectangle()
                                    .fill(Color.liftPrimary)
                                    .frame(width: 2, height: 14)

                                Text(ex.exerciseName.uppercased())
                                    .font(.liftCaption)
                                    .foregroundStyle(Color.liftText)
                                    .lineLimit(1)

                                Text(setsSummary(completedSets))
                                    .font(.liftCaption)
                                    .foregroundStyle(Color.liftMuted)
                            }
                        }
                    }
                }
            }

            // ── Stats row ───────────────────────────────────────────
            Divider()
                .background(Color.liftBorder)

            HStack(spacing: Spacing.xl) {
                stat(label: "VOLUME", value: workout.totalVolumeFormatted)
                stat(label: "EXERCISES", value: "\(workout.sortedExercises.count)")
                stat(label: "SETS", value: "\(workout.totalSets)")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.liftMuted)
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

    private func stat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(0.6)
                .foregroundStyle(Color.liftMuted)
                .textCase(.uppercase)
            Text(value)
                .font(.liftDataSm)
                .foregroundStyle(Color.liftText)
                .monospacedDigit()
        }
    }

    private func setsSummary(_ sets: [WorkoutSet]) -> String {
        // e.g. "3 × 10 @ 80KG" or "3 SETS"
        guard !sets.isEmpty else { return "" }
        let count = sets.count
        let avgWeight = sets.map { $0.weightLbs }.reduce(0, +) / Double(sets.count)
        let avgReps = Int(sets.map { Double($0.reps) }.reduce(0, +) / Double(sets.count))
        if avgWeight > 0 && avgReps > 0 {
            return "(\(count) × \(avgReps) @ \(Int(avgWeight))KG)"
        }
        return "(\(count) SETS)"
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d • h:mm a"
        return f.string(from: workout.startDate).uppercased()
    }
}

#Preview {
    NavigationStack {
        PastWorkoutsView()
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
