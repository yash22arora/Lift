// ProfileView.swift
// Lift — Profile screen with option to clear data

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirm = false

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()

            VStack(spacing: Spacing.xl) {
                // Profile Header
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.liftPrimary)
                    
                    Text("ATHLETE")
                        .font(.liftHeadingMd)
                        .foregroundStyle(Color.liftText)
                }
                .padding(.top, Spacing.xl)

                // Settings List
                VStack(spacing: 0) {
                    settingRow(title: "CLEAR ALL DATA", icon: "trash", color: .red) {
                        showDeleteConfirm = true
                    }
                }
                .background(Color.liftSurface)
                .cornerRadius(Radius.sm)
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.sm)
                        .stroke(Color.liftBorder, lineWidth: BorderWidth.thin)
                )
                .padding(.horizontal, Spacing.md)

                Spacer()
            }
        }
        .navigationTitle("PROFILE")
        .navigationBarTitleDisplayMode(.inline)
        .alert("CLEAR ALL DATA?", isPresented: $showDeleteConfirm) {
            Button("DELETE EVERYTHING", role: .destructive) {
                let repo = WorkoutRepository(modelContext: modelContext)
                repo.clearAllData()
                HapticService.success()
            }
            Button("CANCEL", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your workout history. This action cannot be undone.")
        }
    }

    private func settingRow(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.liftButton)
                    .foregroundStyle(Color.liftText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.liftMuted)
            }
            .padding(Spacing.md)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
