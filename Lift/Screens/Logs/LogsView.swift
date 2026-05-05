// LogsView.swift
// Lift — List of all recorded sets

import SwiftUI
import SwiftData

struct LogsView: View {
    @Query(filter: #Predicate<WorkoutSet> { $0.isCompleted }, sort: \WorkoutSet.completedAt, order: .reverse)
    private var allSets: [WorkoutSet]

    var body: some View {
        ZStack {
            Color.liftBackground.ignoresSafeArea()

            if allSets.isEmpty {
                VStack(spacing: Spacing.md) {
                    Text("NO RECORDED SETS")
                        .font(.liftHeadingMd)
                        .foregroundStyle(Color.liftMuted)
                    Text("START A WORKOUT TO LOG DATA")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: Spacing.sm) {
                        ForEach(allSets) { set in
                            logRow(set)
                        }
                    }
                    .padding(.horizontal, Spacing.md)
                    .padding(.top, Spacing.md)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle("LOGS")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func logRow(_ set: WorkoutSet) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(set.exercise?.exerciseName.uppercased() ?? "UNKNOWN EXERCISE")
                    .font(.liftBodyMd)
                    .foregroundStyle(Color.liftText)
                
                HStack(spacing: 4) {
                    Text(formatDate(set.completedAt ?? Date()))
                    Text("•")
                    Text("SET \(set.setNumber)")
                }
                .font(.liftCaption)
                .foregroundStyle(Color.liftMuted)
            }
            
            Spacer()
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(Int(set.weightLbs))")
                    .font(.liftDataMd)
                    .foregroundStyle(Color.liftPrimary)
                Text("KG")
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
                
                Text("×")
                    .font(.liftCaption)
                    .foregroundStyle(Color.liftMuted)
                    .padding(.horizontal, 2)
                
                Text("\(set.reps)")
                    .font(.liftDataMd)
                    .foregroundStyle(Color.liftPrimary)
                Text("REPS")
                    .font(.liftCaption)
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

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        LogsView()
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
