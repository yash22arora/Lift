// WorkoutSessionCard.swift
// Lift — Recent session card matching dashboard mockup design

import SwiftUI

struct WorkoutSessionCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Title row
            HStack(alignment: .top) {
                Text(workout.name.uppercased())
                    .font(.liftBodyMd)
                    .foregroundStyle(Color.liftText)
                    .lineLimit(1)
                Spacer()
                Text(relativeDate)
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
                    .tracking(0.4)
                    .textCase(.uppercase)
            }

            // Stats row
            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("VOLUME")
                        .liftCaptionStyle()
                    Text(volumeFormatted)
                        .font(.liftDataSm)
                        .foregroundStyle(Color.liftText)
                        .monospacedDigit()
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("DURATION")
                        .liftCaptionStyle()
                    Text(workout.durationFormatted ?? "—")
                        .font(.liftDataSm)
                        .foregroundStyle(Color.liftText)
                        .monospacedDigit()
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

    private var volumeFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: workout.totalVolumeLbs)) ?? "0"
        return "\(formatted) KG"
    }

    private var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()
        let days = calendar.dateComponents([.day], from: workout.startDate, to: now).day ?? 0
        switch days {
        case 0:  return "TODAY"
        case 1:  return "YESTERDAY"
        default: return "\(days) DAYS AGO"
        }
    }
}

// MARK: — Skeleton

struct WorkoutSessionCardSkeleton: View {
    @State private var shimmer = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                SkeletonView(width: 180, height: 16)
                Spacer()
                SkeletonView(width: 80, height: 12)
            }
            HStack(spacing: Spacing.xl) {
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(width: 50, height: 10)
                    SkeletonView(width: 70, height: 16)
                }
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView(width: 60, height: 10)
                    SkeletonView(width: 50, height: 16)
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
