// ActiveWorkoutView.swift
// Lift — Active workout screen with single-exercise focus, matching design mockups

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    let initialExercises: [ExerciseDefinition]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel = ActiveWorkoutViewModel()
    @State private var showFinishConfirm = false

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }

            VStack(spacing: 0) {
                // ─── Timer Header ──────────────────────────────────────
                timerHeader
                Divider().background(Color.liftBorder)

                if viewModel.sortedExercises.isEmpty {
                    emptyState
                } else if let exercise = viewModel.currentExercise {
                    exerciseContent(exercise)
                }
            }
            .padding(.bottom, 70) // Tab bar space

            // ─── Rest Timer Overlay ────────────────────────────────
            if viewModel.showRestTimer {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.liftSpring) { viewModel.showRestTimer = false }
                    }

                RestTimerOverlay(
                    isPresented: $viewModel.showRestTimer,
                    exerciseName: viewModel.restTimerExerciseName,
                    setNumber: viewModel.restTimerSetNumber,
                    restDuration: 90
                ) {
                    viewModel.showRestTimer = false
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.liftSpring, value: viewModel.showRestTimer)
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.showExerciseSelection) {
            ExerciseSelectionView(alreadyAddedExerciseIds: viewModel.alreadyAddedExerciseIds) { definitions in
                viewModel.addExercises(definitions)
                viewModel.showExerciseSelection = false
            }
        }
        .alert("FINISH WORKOUT?", isPresented: $showFinishConfirm) {
            Button("FINISH", role: .destructive) {
                viewModel.finishWorkout()
                dismiss()
            }
            Button("CANCEL", role: .cancel) {}
        } message: {
            Text("This will save your session and stop the timer.")
        }
        .onAppear {
            let repo = WorkoutRepository(modelContext: modelContext)
            viewModel.startWorkout(repository: repo, initialExercises: initialExercises)
        }
    }

    // MARK: — Timer Header

    private var timerHeader: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.liftPrimary)
                Text(viewModel.elapsedFormatted)
                    .font(.liftDataMd)
                    .foregroundStyle(Color.liftPrimary)
                    .monospacedDigit()
            }

            Spacer()

            Button {
                showFinishConfirm = true
            } label: {
                Text("FINISH")
                    .font(.liftCaption)
                    .tracking(1)
                    .foregroundStyle(Color.liftPrimary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.liftPrimary.opacity(0.5), lineWidth: BorderWidth.thin)
                    )
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.liftBackground)
    }

    // MARK: — Exercise Content (single exercise focus)

    @ViewBuilder
    private func exerciseContent(_ exercise: WorkoutExercise) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Exercise name
                Text(exercise.exerciseName.uppercased())
                    .font(.liftHeadingXL)
                    .foregroundStyle(Color.liftText)
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.lg)
                    .padding(.bottom, Spacing.md)

                // Column headers
                HStack(spacing: 0) {
                    Text("SET")
                        .frame(width: 50, alignment: .leading)
                    Text("KG")
                        .frame(maxWidth: .infinity)
                    Text("REPS")
                        .frame(maxWidth: .infinity)
                    Text("")
                        .frame(width: 44)
                }
                .liftCaptionStyle()
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.sm)

                // Set rows
                ForEach(exercise.sortedSets) { set in
                    SetRowView(
                        set: set,
                        exercise: exercise,
                        isActive: !set.isCompleted && isFirstIncompleteSet(set, in: exercise),
                        onComplete: {
                            viewModel.completeSet(set, exercise: exercise)
                        },
                        onDelete: {
                            viewModel.deleteSet(set, from: exercise)
                        }
                    )
                }

                // Add set button
                Button {
                    viewModel.addSet(to: exercise)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("ADD SET")
                            .font(.liftCaption)
                            .tracking(0.8)
                    }
                    .foregroundStyle(Color.liftPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.liftSurface)
                    .cornerRadius(Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
                    )
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)

                // Up Next card
                if let nextEx = viewModel.nextExercise {
                    upNextCard(nextEx)
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.lg)
                }

                // Add exercise button
                Button {
                    viewModel.showExerciseSelection = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("ADD EXERCISE")
                            .font(.liftCaption)
                            .tracking(0.8)
                    }
                    .foregroundStyle(Color.liftMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.liftSurface)
                    .cornerRadius(Radius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.sm)
                            .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
                    )
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: — Up Next Card

    private func upNextCard(_ exercise: WorkoutExercise) -> some View {
        VStack(spacing: 0) {
            ZStack {
                // Blurred background
                RoundedRectangle(cornerRadius: Radius.sm)
                    .fill(Color.liftSurface)
                    .frame(height: 80)

                VStack(spacing: 6) {
                    Text("UP NEXT")
                        .font(.liftCaption)
                        .tracking(0.8)
                        .foregroundStyle(Color.liftText)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, 4)
                        .background(Color.liftSurfaceElevated)
                        .cornerRadius(Radius.pill)

                    Text(exercise.exerciseName.uppercased())
                        .font(.liftBodyMd)
                        .foregroundStyle(Color.liftMuted)
                        .lineLimit(1)
                }
            }
            .onTapGesture {
                viewModel.goToNextExercise()
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
        )
    }

    // MARK: — Empty State

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Text("TAP BELOW TO BUILD\nYOUR ROUTINE")
                .font(.liftButton)
                .foregroundStyle(Color.liftMuted)
                .multilineTextAlignment(.center)

            Button {
                viewModel.showExerciseSelection = true
            } label: {
                Text("+ ADD EXERCISE")
                    .font(.liftButton)
                    .foregroundStyle(Color.liftBackground)
                    .frame(maxWidth: .infinity)
                    .frame(height: ComponentSize.ctaHeight)
                    .background(Color.liftPrimary)
                    .cornerRadius(0)
            }
            .buttonStyle(LiftButtonStyle())
            .padding(.horizontal, Spacing.md)

            Spacer()
        }
    }

    // MARK: — Helpers

    private func isFirstIncompleteSet(_ set: WorkoutSet, in exercise: WorkoutExercise) -> Bool {
        exercise.sortedSets.first(where: { !$0.isCompleted })?.id == set.id
    }
}
