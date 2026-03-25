import SwiftUI

struct EditExerciseSheet: View {
    let exercise: Exercise
    let onSave: (UpdateExerciseRequest) async -> Bool
    let onDelete: () async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedType: ExerciseType
    @State private var notes: String
    @State private var isSaving = false
    @State private var showDeleteConfirmation = false

    init(exercise: Exercise, onSave: @escaping (UpdateExerciseRequest) async -> Bool, onDelete: @escaping () async -> Bool) {
        self.exercise = exercise
        self.onSave = onSave
        self.onDelete = onDelete
        _name = State(initialValue: exercise.name)
        _selectedMuscleGroup = State(initialValue: MuscleGroup(rawValue: exercise.muscleGroup ?? ""))
        _selectedType = State(initialValue: exercise.exerciseType)
        _notes = State(initialValue: exercise.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SisyphusTheme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Name field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            TextField("Exercise name", text: $name)
                                .font(.system(size: 17))
                                .foregroundColor(SisyphusTheme.textPrimary)
                                .padding(14)
                                .background(SisyphusTheme.cardBackground)
                                .cornerRadius(SisyphusTheme.smallRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                        .stroke(SisyphusTheme.cardBorder, lineWidth: 1)
                                )
                        }

                        // Exercise type
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            HStack(spacing: 8) {
                                ForEach(ExerciseType.allCases) { type in
                                    Button(action: { selectedType = type }) {
                                        VStack(spacing: 6) {
                                            Image(systemName: type.icon)
                                                .font(.system(size: 18))
                                            Text(type.displayName)
                                                .font(.system(size: 13, weight: .semibold))
                                            Text(type.subtitle)
                                                .font(.system(size: 10))
                                                .foregroundColor(
                                                    selectedType == type
                                                        ? .black.opacity(0.6)
                                                        : SisyphusTheme.textTertiary
                                                )
                                        }
                                        .foregroundColor(
                                            selectedType == type ? .black : SisyphusTheme.textSecondary
                                        )
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedType == type
                                                ? SisyphusTheme.accent
                                                : SisyphusTheme.cardBackground
                                        )
                                        .cornerRadius(SisyphusTheme.smallRadius)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                                .stroke(
                                                    selectedType == type
                                                        ? SisyphusTheme.accent
                                                        : SisyphusTheme.cardBorder,
                                                    lineWidth: 1
                                                )
                                        )
                                    }
                                }
                            }
                        }

                        // Muscle group
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Muscle Group")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                                ForEach(MuscleGroup.allCases) { group in
                                    Button(action: {
                                        selectedMuscleGroup = selectedMuscleGroup == group ? nil : group
                                    }) {
                                        Text(group.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(
                                                selectedMuscleGroup == group ? .black : SisyphusTheme.textSecondary
                                            )
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedMuscleGroup == group
                                                    ? SisyphusTheme.accent
                                                    : SisyphusTheme.cardBackground
                                            )
                                            .cornerRadius(SisyphusTheme.smallRadius)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                                    .stroke(
                                                        selectedMuscleGroup == group
                                                            ? SisyphusTheme.accent
                                                            : SisyphusTheme.cardBorder,
                                                        lineWidth: 1
                                                    )
                                            )
                                    }
                                }
                            }
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes (Optional)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)

                            TextField("Any tips or form cues...", text: $notes, axis: .vertical)
                                .font(.system(size: 15))
                                .foregroundColor(SisyphusTheme.textPrimary)
                                .lineLimit(3...6)
                                .padding(14)
                                .background(SisyphusTheme.cardBackground)
                                .cornerRadius(SisyphusTheme.smallRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                        .stroke(SisyphusTheme.cardBorder, lineWidth: 1)
                                )
                        }

                        // Delete button
                        Button(action: { showDeleteConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 14))
                                Text("Delete Exercise")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(SisyphusTheme.destructive)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(SisyphusTheme.destructive.opacity(0.1))
                            .cornerRadius(SisyphusTheme.smallRadius)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(SisyphusTheme.textSecondary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        guard !isSaving else { return }
                        isSaving = true
                        Task {
                            let update = UpdateExerciseRequest(
                                name: name,
                                muscleGroup: selectedMuscleGroup?.rawValue,
                                exerciseType: selectedType.rawValue,
                                notes: notes.isEmpty ? nil : notes,
                                sortOrder: nil,
                                isActive: nil
                            )
                            let success = await onSave(update)
                            isSaving = false
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .tint(SisyphusTheme.accent)
                                .scaleEffect(0.8)
                        } else {
                            Text("Save")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .foregroundColor(name.isEmpty ? SisyphusTheme.textTertiary : SisyphusTheme.accent)
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .alert("Delete Exercise?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await onDelete()
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("This will permanently remove \"\(exercise.name)\" from this split.")
            }
        }
    }
}
