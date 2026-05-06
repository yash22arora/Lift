// WorkoutSessionCard.swift
// Lift — Recent session card matching dashboard mockup design

import SwiftUI

struct WorkoutSessionCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {

            // ── Header row ─────────────────────────────────────────
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(workout.name.uppercased())
                        .font(.liftBodyMd)
                        .foregroundStyle(Color.liftText)
                        .lineLimit(1)

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

            // ── Stats footer ────────────────────────────────────────
            Divider().background(Color.liftBorder)

            HStack(spacing: Spacing.xl) {
                stat(label: "VOLUME",   value: volumeFormatted)
                stat(label: "DURATION", value: workout.durationFormatted ?? "—")
                stat(label: "SETS",     value: "\(workout.totalSets)")
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
            Text(value)
                .font(.liftDataSm)
                .foregroundStyle(Color.liftText)
                .monospacedDigit()
        }
    }

    private func setsSummary(_ sets: [WorkoutSet]) -> String {
        guard !sets.isEmpty else { return "" }
        let count = sets.count
        let avgWeight = sets.map { $0.weightKg }.reduce(0, +) / Double(count)
        let avgReps = Int(sets.map { Double($0.reps) }.reduce(0, +) / Double(count))
        if avgWeight > 0 && avgReps > 0 {
            return "(\(count) × \(avgReps) @ \(Int(avgWeight))KG)"
        }
        return "(\(count) SETS)"
    }

    private var volumeFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: workout.totalVolumeKg)) ?? "0"
        return "\(formatted) KG"
    }

    private var formattedDate: String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: workout.startDate, to: now).day ?? 0
        let timeStr: String = {
            let f = DateFormatter()
            f.dateFormat = "h:mm a"
            return f.string(from: workout.startDate)
        }()
        switch days {
        case 0:  return "TODAY • \(timeStr)".uppercased()
        case 1:  return "YESTERDAY • \(timeStr)".uppercased()
        default:
            let f = DateFormatter()
            f.dateFormat = "MMM d"
            return "\(f.string(from: workout.startDate).uppercased()) • \(timeStr.uppercased())"
        }
    }
}

// MARK: — Skeleton

struct WorkoutSessionCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    SkeletonView(width: 160, height: 14)
                    SkeletonView(width: 110, height: 10)
                }
                Spacer()
                SkeletonView(width: 40, height: 14)
            }
            VStack(alignment: .leading, spacing: 6) {
                SkeletonView(width: 220, height: 10)
                SkeletonView(width: 180, height: 10)
            }
            Divider().background(Color.liftBorder)
            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(width: 44, height: 8)
                    SkeletonView(width: 60, height: 14)
                }
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(width: 52, height: 8)
                    SkeletonView(width: 36, height: 14)
                }
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(width: 32, height: 8)
                    SkeletonView(width: 24, height: 14)
                }
                Spacer()
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
