// LogsView.swift
// Lift — List of all recorded sets

import SwiftUI
import SwiftData

struct LogsView: View {
    @Query(filter: #Predicate<WorkoutSet> { $0.isCompleted }, sort: \WorkoutSet.completedAt, order: .reverse)
    private var allSets: [WorkoutSet]

    @Environment(\.modelContext) private var modelContext

    @State private var editingSetID: UUID?
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case weight(UUID)
        case reps(UUID)
    }

    var body: some View {
        ZStack {
            Color.liftBackground
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                    editingSetID = nil
                }

            if allSets.isEmpty {
                VStack(spacing: Spacing.xs) {
                    Text("NO RECORDED SETS")
                        .font(.liftHeadingMd)
                        .foregroundStyle(Color.liftMuted)
                    Text("START A WORKOUT TO LOG DATA")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                }
            } else {
                List {
                    // Top padding buffer
                    Color.clear
                        .frame(height: Spacing.xs)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())

                    ForEach(allSets) { set in
                        LogRowView(
                            set: set,
                            editingSetID: $editingSetID,
                            focusedField: $focusedField,
                            onDelete: { deleteSet(set) }
                        )
                    }
                    
                    // Bottom padding buffer
                    Color.clear
                        .frame(height: Spacing.sm)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .onTapGesture {
                    focusedField = nil
                    editingSetID = nil
                }
            }
        }
        .onChange(of: focusedField) { _, newValue in
            if newValue == nil {
                editingSetID = nil
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("LOGS")
                    .font(.liftBody)
                    .foregroundStyle(Color.liftPrimary)
            }
        }
        .toolbarBackground(.automatic, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func deleteSet(_ set: WorkoutSet) {
        modelContext.delete(set)
    }
}

struct LogRowView: View {
    @Bindable var set: WorkoutSet
    @Binding var editingSetID: UUID?
    var focusedField: FocusState<LogsView.Field?>.Binding
    var onDelete: () -> Void

    var body: some View {
        let isEditing = editingSetID == set.id

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
            
            if isEditing {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    // Weight Input
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        TextField("", value: $set.weightKg, format: .number)
                            .focused(focusedField, equals: .weight(set.id))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .font(.liftDataMd)
                            .foregroundStyle(Color.liftPrimary)
                        Text("KG")
                            .font(.liftCaption)
                            .foregroundStyle(Color.liftMuted)
                    }
                    
                    Text("×")
                        .font(.liftCaption)
                        .foregroundStyle(Color.liftMuted)
                        .padding(.horizontal, 2)
                    
                    // Reps Input
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        TextField("", value: $set.reps, format: .number)
                            .focused(focusedField, equals: .reps(set.id))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 40)
                            .font(.liftDataMd)
                            .foregroundStyle(Color.liftPrimary)
                        Text("REPS")
                            .font(.liftCaption)
                            .foregroundStyle(Color.liftMuted)
                    }
                }
            } else {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(set.weightKg))")
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
        }
        .padding(Spacing.md)
        .background(isEditing ? Color.liftPrimary.opacity(0.1) : Color.liftSurface)
        .cornerRadius(Radius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: Radius.sm)
                .stroke(isEditing ? Color.liftPrimary : Color.liftBorder, 
                        lineWidth: isEditing ? BorderWidth.thick : BorderWidth.thin)
        )
        .listRowInsets(EdgeInsets(top: Spacing.xs, leading: Spacing.md, bottom: Spacing.xs, trailing: Spacing.md))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .swipeActions(edge: .leading) {
            Button {
                editingSetID = set.id
                focusedField.wrappedValue = .weight(set.id)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(Color.liftPrimary)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(Color.liftAccent)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, HH:mm"
        return formatter
    }()

    private func formatDate(_ date: Date) -> String {
        return Self.dateFormatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        LogsView()
    }
    .modelContainer(for: [Workout.self, WorkoutExercise.self, WorkoutSet.self], inMemory: true)
}
