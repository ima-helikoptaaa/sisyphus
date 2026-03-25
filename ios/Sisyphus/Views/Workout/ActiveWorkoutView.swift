import SwiftUI

struct ActiveWorkoutView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showFinishConfirmation = false
    @State private var showDiscardConfirmation = false
    @State private var showRestTimer = false

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Workout header
                workoutHeader

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .tint(SisyphusTheme.accent)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Error banner
                            if let error = viewModel.errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(SisyphusTheme.destructive)
                                    Text(error)
                                        .font(.system(size: 13))
                                        .foregroundColor(SisyphusTheme.destructive)
                                    Spacer()
                                    Button(action: { viewModel.errorMessage = nil }) {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(SisyphusTheme.textTertiary)
                                    }
                                }
                                .padding(12)
                                .background(SisyphusTheme.destructive.opacity(0.1))
                                .cornerRadius(SisyphusTheme.smallRadius)
                            }

                            // Stats bar
                            statsBar

                            // Rest timer (inline)
                            if viewModel.isRestTimerRunning {
                                RestTimerView(
                                    timeRemaining: viewModel.restTimerSeconds,
                                    totalTime: viewModel.restTimerTotal,
                                    onDismiss: { viewModel.stopRestTimer() },
                                    onChangeTime: { duration in
                                        viewModel.startRestTimer(duration: duration)
                                    }
                                )
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }

                            // Exercise logs
                            ForEach(Array(viewModel.exerciseLogs.enumerated()), id: \.element.id) { index, log in
                                ExerciseLogCard(
                                    exerciseLog: log,
                                    previousSets: viewModel.previousSetsForExercise(exerciseId: log.exerciseId),
                                    onAddSet: { weight, reps, durationSecs, rpe, isWarmup, isDropset in
                                        Task {
                                            await viewModel.addSet(
                                                exerciseLogId: log.id,
                                                weight: weight,
                                                reps: reps,
                                                durationSecs: durationSecs,
                                                rpe: rpe,
                                                isWarmup: isWarmup,
                                                isDropset: isDropset
                                            )
                                        }
                                    },
                                    onDeleteSet: { setId in
                                        Task {
                                            await viewModel.deleteSet(exerciseLogId: log.id, setId: setId)
                                        }
                                    },
                                    onSkip: { skip in
                                        Task {
                                            await viewModel.skipExercise(exerciseLogId: log.id, skip: skip)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }

                // Bottom action bar
                bottomActionBar
            }
        }
        .navigationBarHidden(true)
        .alert("Finish Workout?", isPresented: $showFinishConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Finish") {
                Task {
                    let success = await viewModel.finishWorkout()
                    if success { dismiss() }
                }
            }
        } message: {
            Text("Complete this workout session with \(viewModel.totalSets) sets logged.")
        }
        .alert("Discard Workout?", isPresented: $showDiscardConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Discard", role: .destructive) {
                Task {
                    let success = await viewModel.discardWorkout()
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This will permanently delete all logged sets from this session.")
        }
        .animation(.spring(response: 0.3), value: viewModel.isRestTimerRunning)
        .animation(.spring(response: 0.3), value: viewModel.errorMessage != nil)
    }

    // MARK: - Header
    private var workoutHeader: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(SisyphusTheme.textSecondary)
                    .frame(width: 36, height: 36)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.currentSession?.splitName ?? "Workout")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Text(viewModel.elapsedTimeFormatted)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(SisyphusTheme.accent)
            }

            Spacer()

            Button(action: { showDiscardConfirmation = true }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(SisyphusTheme.destructive)
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(SisyphusTheme.background)
    }

    // MARK: - Stats
    private var statsBar: some View {
        HStack(spacing: 0) {
            WorkoutStatItem(
                title: "Volume",
                value: formatVolume(viewModel.totalVolume)
            )
            WorkoutStatItem(
                title: "Sets",
                value: "\(viewModel.totalSets)"
            )
            WorkoutStatItem(
                title: "Duration",
                value: viewModel.elapsedTimeFormatted
            )
        }
        .padding(.vertical, 12)
        .background(SisyphusTheme.cardBackground)
        .cornerRadius(SisyphusTheme.cardRadius)
        .overlay(
            RoundedRectangle(cornerRadius: SisyphusTheme.cardRadius)
                .stroke(SisyphusTheme.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Bottom Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(SisyphusTheme.cardBorder)

            HStack(spacing: 16) {
                // Rest timer button
                Button(action: {
                    if viewModel.isRestTimerRunning {
                        viewModel.stopRestTimer()
                    } else {
                        viewModel.startRestTimer()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "timer")
                            .font(.system(size: 16))
                        if viewModel.isRestTimerRunning {
                            Text(viewModel.restTimerFormatted)
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                        } else {
                            Text("Rest")
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    .foregroundColor(viewModel.isRestTimerRunning ? SisyphusTheme.accent : SisyphusTheme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(SisyphusTheme.cardBackground)
                    .cornerRadius(SisyphusTheme.smallRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                            .stroke(
                                viewModel.isRestTimerRunning ? SisyphusTheme.accent.opacity(0.3) : SisyphusTheme.cardBorder,
                                lineWidth: 1
                            )
                    )
                }

                Spacer()

                // Finish button
                Button(action: { showFinishConfirmation = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                        Text("Finish")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(SisyphusTheme.accent)
                    .cornerRadius(SisyphusTheme.buttonRadius)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(SisyphusTheme.background)
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return "\(Int(volume))"
    }
}

struct WorkoutStatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(SisyphusTheme.textPrimary)
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(SisyphusTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ActiveWorkoutView()
        .environmentObject(WorkoutViewModel())
}
