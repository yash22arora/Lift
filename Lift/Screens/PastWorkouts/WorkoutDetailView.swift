// WorkoutDetailView.swift
// Lift — Full detail view for a single completed workout

import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    let workout: Workout

    private let exerciseRepo = ExerciseRepository.shared

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {

                    // ── Header card ─────────────────────────────────────
                    summaryHeader

                    // ── Exercises ───────────────────────────────────────
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("EXERCISES")
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.2)
                            .foregroundStyle(Color.liftMuted)

                        ForEach(workout.sortedExercises) { exercise in
                            exerciseCard(exercise)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, 48)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(workout.name.uppercased())
                    .font(.liftBody)
                    .foregroundStyle(Color.liftPrimary)
            }
        }
        .toolbarBackground(.automatic, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: — Summary Header

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDate)
                    .font(.liftBodyMd)
                    .foregroundStyle(Color.liftText)
                Text(formattedTime)
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
            }

            Divider().background(Color.liftBorder)

            // Stats grid
            HStack(spacing: 0) {
                statCell(label: "DURATION",  value: workout.durationFormatted ?? "—")
                dividerLine
                statCell(label: "VOLUME",    value: workout.totalVolumeFormatted)
                dividerLine
                statCell(label: "EXERCISES", value: "\(workout.sortedExercises.count)")
                dividerLine
                statCell(label: "SETS",      value: "\(workout.totalSets)")
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

    private var dividerLine: some View {
        Rectangle()
            .fill(Color.liftBorder)
            .frame(width: BorderWidth.thin)
            .frame(height: 36)
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.liftDataSm)
                .foregroundStyle(Color.liftPrimary)
                .monospacedDigit()
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .tracking(0.6)
                .foregroundStyle(Color.liftMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Exercise Card

    private func exerciseCard(_ exercise: WorkoutExercise) -> some View {
        let definition = exerciseRepo.exercise(for: exercise.exerciseDefinitionId)
        let completedSets = exercise.sortedSets.filter { $0.isCompleted }

        return VStack(alignment: .leading, spacing: 0) {

            // Exercise header
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(exercise.exerciseName.uppercased())
                        .font(.liftBodyMd)
                        .foregroundStyle(Color.liftText)
                    Spacer()
                    Text("\(completedSets.count) SETS")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }

                // Muscle group tags
                if let def = definition, !def.muscleGroups.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(def.muscleGroups, id: \.self) { muscle in
                            muscleTag(muscle)
                        }
                        Spacer()
                        // Category badge
                        Text(def.category.rawValue.uppercased())
                            .font(.system(size: 9, weight: .medium))
                            .tracking(0.6)
                            .foregroundStyle(Color.liftMuted)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.liftSurfaceElevated)
                            .cornerRadius(Radius.pill)
                    }
                }
            }
            .padding(Spacing.md)

            if !completedSets.isEmpty {
                Divider().background(Color.liftBorder).padding(.horizontal, Spacing.md)

                // Column headers
                HStack(spacing: 0) {
                    Text("SET")
                        .frame(width: 40, alignment: .leading)
                    Text("WEIGHT")
                        .frame(maxWidth: .infinity)
                    Text("REPS")
                        .frame(maxWidth: .infinity)
                    Text("1RM EST.")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.system(size: 10, weight: .semibold))
                .tracking(0.6)
                .foregroundStyle(Color.liftMuted)
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
                .padding(.bottom, 4)

                // Set rows
                ForEach(completedSets) { set in
                    setRow(set, isLast: set.id == completedSets.last?.id)
                }

                // Best 1RM footer if available
                if let best = exercise.bestEstimated1RM {
                    Divider().background(Color.liftBorder).padding(.horizontal, Spacing.md)
                    HStack {
                        Text("BEST ESTIMATED 1RM")
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(0.6)
                            .foregroundStyle(Color.liftMuted)
                        Spacer()
                        Text(String(format: "%.1f KG", best))
                            .font(.liftDataSm)
                            .foregroundStyle(Color.liftPrimary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                }
            }
        }
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
        )
    }

    private func setRow(_ set: WorkoutSet, isLast: Bool) -> some View {
        HStack(spacing: 0) {
            // Set number with neon accent
            Text("\(set.setNumber)")
                .font(.liftDataSm)
                .foregroundStyle(Color.liftPrimary)
                .monospacedDigit()
                .frame(width: 40, alignment: .leading)

            Text(set.weightKg > 0 ? "\(Int(set.weightKg)) KG" : "—")
                .font(.liftBodyMd)
                .foregroundStyle(Color.liftText)
                .monospacedDigit()
                .frame(maxWidth: .infinity)

            Text("\(set.reps) REPS")
                .font(.liftBodyMd)
                .foregroundStyle(Color.liftText)
                .monospacedDigit()
                .frame(maxWidth: .infinity)

            if let orm = set.estimatedOneRepMax {
                Text(String(format: "%.0f KG", orm))
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
                    .monospacedDigit()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            } else {
                Text("—")
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, 10)
        .background(set.setNumber % 2 == 0 ? Color.liftSurfaceElevated.opacity(0.4) : Color.clear)
    }

    private func muscleTag(_ muscle: MuscleGroup) -> some View {
        HStack(spacing: 3) {
            Image(systemName: muscle.icon)
                .font(.system(size: 9))
            Text(muscle.rawValue.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(0.4)
        }
        .foregroundStyle(Color.liftPrimary)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Color.liftPrimary.opacity(0.12))
        .cornerRadius(Radius.pill)
    }

    // MARK: — Date Helpers

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f.string(from: workout.startDate).uppercased()
    }

    private var formattedTime: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        let start = f.string(from: workout.startDate)
        if let end = workout.endDate {
            return "\(start) – \(f.string(from: end))".uppercased()
        }
        return start.uppercased()
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(workout: Workout(name: "Push Day"))
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
