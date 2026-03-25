import SwiftUI

struct SplitDetailView: View {
    let splitId: String
    @StateObject private var viewModel = SplitsViewModel()
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var showingAddExercise = false
    @State private var showingActiveWorkout = false
    @State private var editingExercise: Exercise?
    @State private var isEditing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            SisyphusTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                if let split = viewModel.selectedSplit {
                    splitHeader(split)
                }

                if viewModel.exercises.isEmpty && !viewModel.isLoading {
                    Spacer()
                    EmptyStateView(
                        icon: "list.bullet.rectangle",
                        title: "No Exercises",
                        subtitle: "Add exercises to this split to build your workout routine.",
                        actionTitle: "Add Exercise"
                    ) {
                        showingAddExercise = true
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.exercises) { exercise in
                                ExerciseDetailCard(
                                    exercise: exercise,
                                    onTap: { editingExercise = exercise }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .tint(SisyphusTheme.accent)
                        .padding()
                }
            }

            // Start Workout Button
            VStack(spacing: 0) {
                LinearGradient(
                    colors: [SisyphusTheme.background.opacity(0), SisyphusTheme.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 32)

                HStack(spacing: 12) {
                    SisyphusButton(
                        title: "Start Workout",
                        icon: "play.fill",
                        style: .primary,
                        isLoading: workoutViewModel.isLoading,
                        isDisabled: viewModel.exercises.isEmpty
                    ) {
                        Task {
                            let success = await workoutViewModel.startWorkout(splitId: splitId)
                            if success {
                                showingActiveWorkout = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(SisyphusTheme.background)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddExercise = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(SisyphusTheme.accent)
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseSheet { name, muscleGroup, exerciseType, notes in
                await viewModel.createExercise(
                    splitId: splitId, name: name, muscleGroup: muscleGroup,
                    exerciseType: exerciseType, notes: notes
                )
            }
            .presentationDetents([.large])
        }
        .sheet(item: $editingExercise) { exercise in
            EditExerciseSheet(
                exercise: exercise,
                onSave: { update in
                    await viewModel.updateExercise(splitId: splitId, exerciseId: exercise.id, update: update)
                },
                onDelete: {
                    await viewModel.deleteExercise(splitId: splitId, exerciseId: exercise.id)
                }
            )
            .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showingActiveWorkout) {
            NavigationStack {
                ActiveWorkoutView()
                    .environmentObject(workoutViewModel)
            }
        }
        .task {
            await viewModel.loadSplit(id: splitId)
        }
    }

    // MARK: - Split Header

    @ViewBuilder
    private func splitHeader(_ split: WorkoutSplit) -> some View {
        VStack(spacing: 12) {
            Text(split.emoji)
                .font(.system(size: 44))
                .frame(width: 72, height: 72)
                .background(Color(hex: split.color).opacity(0.15))
                .cornerRadius(20)

            VStack(spacing: 4) {
                Text(split.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Text("\(viewModel.exercises.count) exercise\(viewModel.exercises.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(SisyphusTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
}

// MARK: - Exercise Detail Card

struct ExerciseDetailCard: View {
    let exercise: Exercise
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Type icon
                Image(systemName: exercise.exerciseType.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SisyphusTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(SisyphusTheme.accent.opacity(0.12))
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let muscleGroup = exercise.muscleGroup {
                            Text(muscleGroup)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(SisyphusTheme.accent)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 2)
                                .background(SisyphusTheme.accent.opacity(0.12))
                                .cornerRadius(4)
                        }

                        Text(exercise.exerciseType.subtitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SisyphusTheme.textTertiary)
                    }
                }

                Spacer()

                if let notes = exercise.notes, !notes.isEmpty {
                    Image(systemName: "note.text")
                        .font(.system(size: 12))
                        .foregroundColor(SisyphusTheme.textTertiary)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SisyphusTheme.textTertiary)
            }
            .padding(14)
            .background(SisyphusTheme.cardBackground)
            .cornerRadius(SisyphusTheme.cardRadius)
            .overlay(
                RoundedRectangle(cornerRadius: SisyphusTheme.cardRadius)
                    .stroke(SisyphusTheme.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .opacity(exercise.isActive ? 1.0 : 0.5)
    }
}

#Preview {
    NavigationStack {
        SplitDetailView(splitId: "1")
            .environmentObject(WorkoutViewModel())
    }
}
