import SwiftUI

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var selectedMuscleGroup: MuscleGroup?
    @State private var selectedType: ExerciseType = .weighted
    @State private var notes = ""
    @State private var isSaving = false

    let onSave: (String, String?, String, String?) async -> Bool

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

                            TextField("e.g., Bench Press, Squats", text: $name)
                                .font(.system(size: 17))
                                .foregroundColor(SisyphusTheme.textPrimary)
                                .padding(14)
                                .background(SisyphusTheme.cardBackground)
                                .cornerRadius(SisyphusTheme.smallRadius)
                                .overlay(
                                    RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                                        .stroke(SisyphusTheme.cardBorder, lineWidth: 1)
                                )
                                .onChange(of: name) { _, newValue in
                                    if newValue.count > 100 {
                                        name = String(newValue.prefix(100))
                                    }
                                }
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
                                        if selectedMuscleGroup == group {
                                            selectedMuscleGroup = nil
                                        } else {
                                            selectedMuscleGroup = group
                                        }
                                    }) {
                                        Text(group.rawValue)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(
                                                selectedMuscleGroup == group
                                                    ? .black
                                                    : SisyphusTheme.textSecondary
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
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Exercise")
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
                            let success = await onSave(
                                name,
                                selectedMuscleGroup?.rawValue,
                                selectedType.rawValue,
                                notes.isEmpty ? nil : notes
                            )
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
                    .foregroundColor(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? SisyphusTheme.textTertiary : SisyphusTheme.accent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || name.count > 100 || isSaving)
                }
            }
        }
    }
}

#Preview {
    AddExerciseSheet { _, _, _, _ in true }
}
