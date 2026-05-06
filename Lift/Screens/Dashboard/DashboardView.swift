// DashboardView.swift
// Lift — Main dashboard matching the design mockups

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DashboardViewModel()
    @State private var navigateToWorkout = false
    @State private var showExerciseSelection = false
    @State private var selectedExercises: [ExerciseDefinition] = []
    @State private var heroScrolledPast = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.liftBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    heroCard
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onChange(of: geo.frame(in: .global).maxY) { _, newVal in
                                        let past = newVal < 80
                                        if past != heroScrolledPast {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                heroScrolledPast = past
                                            }
                                        }
                                    }
                            }
                        )
                    dailyMetrics
                    recentHistory
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, ComponentSize.ctaHeight + 100)
            }
            .scrollBounceBehavior(.basedOnSize)

            // ─── Sticky Start CTA ──────────────────────────────────
            VStack(spacing: 0) {
                Button {
                    showExerciseSelection = true
                } label: {
                    Text("START WORKOUT")
                        .font(.liftButton)
                        .tracking(1)
                        .foregroundStyle(Color.liftBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: ComponentSize.ctaHeight)
                        .background(Color.liftPrimary)
                        .cornerRadius(0)
                }
                .buttonStyle(LiftButtonStyle(haptic: .heavy))
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("TRAIN")
                    .font(.liftBody)
                    .foregroundStyle(Color.liftPrimary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.load(repository: WorkoutRepository(modelContext: modelContext))
        }
        .sheet(isPresented: $showExerciseSelection) {
            ExerciseSelectionView { definitions in
                selectedExercises = definitions
                showExerciseSelection = false
                // Navigate after a brief delay to allow sheet dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    navigateToWorkout = true
                }
            }
        }
        .navigationDestination(isPresented: $navigateToWorkout) {
            ActiveWorkoutView(initialExercises: selectedExercises)
        }
    }

    // MARK: — Hero Card

    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Background image
            Image("dashboard_hero")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.liftBackground.opacity(0),
                            Color.liftBackground.opacity(0.6),
                            Color.liftBackground.opacity(0.95)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Text overlay
            VStack(alignment: .leading, spacing: 4) {
                Text("LAST SYNC: 10 MINS AGO")
                    .font(.liftCaption)
                    .tracking(0.6)
                    .foregroundStyle(Color.liftPrimary)
                Text("READY TO GRIND")
                    .font(.liftHeadingMd)
                    .foregroundStyle(Color.liftText)
            }
            .padding(Spacing.md)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .clipped()
    }

    // MARK: — Daily Metrics

    private var dailyMetrics: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("DAILY METRICS")
                .liftCaptionStyle()
                .padding(.bottom, 2)

            // Steps widget
            stepsWidget

            // Weekly frequency
            weeklyFrequencyWidget
        }
    }

    private var stepsWidget: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("STEPS")
                    .font(.liftBodyMd)
                    .foregroundStyle(Color.liftText)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(viewModel.stepsFormatted)
                        .font(.liftDataMd)
                        .foregroundStyle(Color.liftText)
                        .monospacedDigit()
                    Text("/ 10K")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            }
            NeonProgressBar(value: viewModel.stepProgress, height: 6)
        }
        .padding(Spacing.md)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
        )
    }

    private var weeklyFrequencyWidget: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                Text("WEEKLY FREQUENCY")
                    .font(.liftBodyMd)
                    .foregroundStyle(Color.liftText)
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(viewModel.weeklyWorkoutCount)")
                        .font(.liftDataMd)
                        .foregroundStyle(Color.liftText)
                        .monospacedDigit()
                    Text("/ 5 DAYS")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            }

            // 5 frequency blocks
            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    Rectangle()
                        .fill(index < viewModel.weeklyWorkoutCount ? Color.liftPrimary : Color.liftSurfaceElevated)
                        .frame(height: 8)
                        .cornerRadius(0)
                }
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

    // MARK: — Recent History

    private var recentHistory: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("RECENT HISTORY")
                    .liftCaptionStyle()
                Spacer()
                NavigationLink(destination: PastWorkoutsView()) {
                    Text("VIEW ALL")
                        .font(.liftCaption)
                        .tracking(0.6)
                        .foregroundStyle(Color.liftPrimary)
                }
            }

            if viewModel.isLoadingWorkouts {
                ForEach(0..<2, id: \.self) { _ in
                    WorkoutSessionCardSkeleton()
                }
            } else if viewModel.recentWorkouts.isEmpty {
                emptyWorkoutsCard
            } else {
                ForEach(viewModel.recentWorkouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutSessionCard(workout: workout)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var emptyWorkoutsCard: some View {
        VStack(spacing: Spacing.sm) {
            Text("NO HISTORY. MAKE SOME.")
                .font(.liftButton)
                .foregroundStyle(Color.liftMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.xl)
        .background(Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
        )
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
