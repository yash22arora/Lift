// RestTimerOverlay.swift
// Lift — Bottom sheet rest timer that appears after completing a set

import SwiftUI

struct RestTimerOverlay: View {
    @Binding var isPresented: Bool
    let exerciseName: String
    let setNumber: Int
    let restDuration: TimeInterval
    let onSkip: () -> Void

    @State private var remaining: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var progress: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: Spacing.lg) {
                // Handle
                Rectangle()
                    .fill(Color.liftBorder)
                    .frame(width: 36, height: 3)

                // Label
                VStack(spacing: Spacing.xs) {
                    Text("REST")
                        .font(.liftHeadingMd)
                        .foregroundStyle(Color.liftPrimary)

                    Text("\(exerciseName.uppercased()) — SET \(setNumber)")
                        .liftCaptionStyle()
                        .multilineTextAlignment(.center)
                }

                // Timer ring
                ZStack {
                    Circle()
                        .stroke(Color.liftSurface, lineWidth: 6)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.liftPrimary, style: StrokeStyle(lineWidth: 6, lineCap: .square))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: .liftPrimary.opacity(0.5), radius: 6)
                        .animation(.liftSmooth, value: progress)

                    Text(timeString(remaining))
                        .font(.liftDataLg)
                        .foregroundStyle(Color.liftText)
                        .monospacedDigit()
                }

                // Actions
                HStack(spacing: Spacing.md) {
                    Button {
                        addTime(15)
                    } label: {
                        Text("+15s")
                            .font(.liftButton)
                            .tracking(0.6)
                            .foregroundStyle(Color.liftMuted)
                            .padding(.horizontal, Spacing.md)
                            .padding(.vertical, Spacing.sm)
                            .background(Color.liftSurface)
                            .cornerRadius(Radius.sm)
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.sm)
                                    .stroke(Color.liftPrimary.opacity(0.4), lineWidth: BorderWidth.thin)
                            )
                    }
                    .frame(height: 48)

                    PrimaryButton("SKIP REST", height: 48) {
                        onSkip()
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.xl)
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(Color.liftBackground.opacity(0.92))
                    .cornerRadius(0)
            )
            .overlay(
                Rectangle()
                    .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
            )
        }
        .padding(.bottom, 80)
        .ignoresSafeArea()
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    // MARK: — Timer Logic

    private func startTimer() {
        remaining = restDuration
        progress = 1.0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            MainActor.assumeIsolated {
                if remaining > 0 {
                    remaining -= 1
                    progress = remaining / restDuration
                    HapticService.selectionChanged()
                } else {
                    HapticService.success()
                    dismiss()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func dismiss() {
        stopTimer()
        withAnimation(.liftSpring) { isPresented = false }
    }

    private func addTime(_ seconds: TimeInterval) {
        remaining += seconds
        if remaining > restDuration {
            progress = remaining / restDuration
        }
        HapticService.lightImpact()
    }

    private func timeString(_ t: TimeInterval) -> String {
        let minutes = Int(t) / 60
        let secs = Int(t) % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}

#Preview {
    ZStack {
        Color.liftBackground.ignoresSafeArea()
        RestTimerOverlay(
            isPresented: .constant(true),
            exerciseName: "Barbell Bench Press",
            setNumber: 3,
            restDuration: 90
        ) {}
    }
}
