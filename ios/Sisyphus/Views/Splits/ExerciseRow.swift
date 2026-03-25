import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.exerciseType.icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SisyphusTheme.accent)
                .frame(width: 32, height: 32)
                .background(SisyphusTheme.accent.opacity(0.12))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SisyphusTheme.textPrimary)

                HStack(spacing: 8) {
                    if let muscleGroup = exercise.muscleGroup {
                        Text(muscleGroup)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SisyphusTheme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(SisyphusTheme.accent.opacity(0.15))
                            .cornerRadius(4)
                    }

                    Text(exercise.exerciseType.subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(SisyphusTheme.textTertiary)

                    if let notes = exercise.notes, !notes.isEmpty {
                        Image(systemName: "note.text")
                            .font(.system(size: 12))
                            .foregroundColor(SisyphusTheme.textTertiary)
                    }
                }
            }

            Spacer()

            if !exercise.isActive {
                Text("Inactive")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SisyphusTheme.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SisyphusTheme.cardBorder)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
        .opacity(exercise.isActive ? 1.0 : 0.5)
    }
}

#Preview {
    List {
        ExerciseRow(exercise: Exercise(
            id: "1",
            splitId: "1",
            name: "Bench Press",
            muscleGroup: "Chest",
            exerciseType: .weighted,
            notes: "Keep elbows at 45 degrees",
            sortOrder: 0,
            isActive: true,
            createdAt: Date(),
            updatedAt: Date()
        ))
        .listRowBackground(SisyphusTheme.cardBackground)
    }
    .listStyle(.plain)
    .background(SisyphusTheme.background)
}
