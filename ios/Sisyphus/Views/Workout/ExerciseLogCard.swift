import SwiftUI

struct ExerciseLogCard: View {
    let exerciseLog: ExerciseLog
    let previousSets: [SetLog]
    let onAddSet: (Double?, Int?, Int?, Double?, Bool, Bool) -> Void
    let onDeleteSet: (String) -> Void
    let onSkip: (Bool) -> Void

    @State private var newWeight: String = ""
    @State private var newReps: String = ""
    @State private var newDuration: String = ""
    @State private var newRPE: Double = 0
    @State private var isWarmup = false
    @State private var isDropset = false
    @State private var isExpanded = true

    private var exerciseType: ExerciseType { exerciseLog.exerciseType }

    var body: some View {
        SisyphusCard(padding: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                exerciseHeader

                if isExpanded && !exerciseLog.isSkipped {
                    Divider()
                        .background(SisyphusTheme.cardBorder)

                    // Previous performance reference
                    if !previousSets.isEmpty {
                        PreviousPerformanceView(previousSets: previousSets, exerciseType: exerciseType)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                    }

                    // Column headers
                    setColumnHeaders
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    // Logged sets
                    ForEach(exerciseLog.sets ?? []) { setLog in
                        SetLogRow(
                            setLog: setLog,
                            previousSet: previousSetForNumber(setLog.setNumber),
                            exerciseType: exerciseType,
                            onDelete: { onDeleteSet(setLog.id) }
                        )
                        .padding(.horizontal, 16)
                    }

                    // Empty state for no sets
                    if exerciseLog.sets?.isEmpty ?? true {
                        Text("No sets logged yet")
                            .font(.system(size: 13))
                            .foregroundColor(SisyphusTheme.textTertiary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }

                    // Add set input row
                    addSetRow
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
        }
        .opacity(exerciseLog.isSkipped ? 0.5 : 1.0)
    }

    // MARK: - Header
    private var exerciseHeader: some View {
        HStack {
            Button(action: { withAnimation(.spring(response: 0.3)) { isExpanded.toggle() } }) {
                HStack(spacing: 10) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textTertiary)
                        .frame(width: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(exerciseLog.exerciseName ?? "Exercise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(SisyphusTheme.textPrimary)

                        HStack(spacing: 6) {
                            if let muscle = exerciseLog.muscleGroup {
                                Text(muscle)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(SisyphusTheme.accent)
                            }

                            if exerciseType != .weighted {
                                Image(systemName: exerciseType.icon)
                                    .font(.system(size: 10))
                                    .foregroundColor(SisyphusTheme.textTertiary)
                                Text(exerciseType.displayName)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(SisyphusTheme.textTertiary)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Set count badge
            if let sets = exerciseLog.sets, !sets.isEmpty {
                Text("\(sets.count) sets")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SisyphusTheme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(SisyphusTheme.cardBorder.opacity(0.5))
                    .cornerRadius(4)
            }

            // Skip toggle
            Button(action: { onSkip(!exerciseLog.isSkipped) }) {
                Image(systemName: exerciseLog.isSkipped ? "forward.fill" : "forward")
                    .font(.system(size: 14))
                    .foregroundColor(exerciseLog.isSkipped ? SisyphusTheme.warning : SisyphusTheme.textTertiary)
            }
            .padding(.leading, 8)
        }
        .padding(16)
    }

    // MARK: - Column Headers
    private var setColumnHeaders: some View {
        HStack(spacing: 0) {
            Text("SET")
                .frame(width: 40, alignment: .leading)
            Text("PREV")
                .frame(width: 80, alignment: .leading)

            switch exerciseType {
            case .weighted:
                Text("KG")
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("REPS")
                    .frame(maxWidth: .infinity, alignment: .center)
            case .bodyweight:
                Text("REPS")
                    .frame(maxWidth: .infinity, alignment: .center)
            case .timed:
                Text("SECS")
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Text("")
                .frame(width: 32)
        }
        .font(.system(size: 11, weight: .semibold))
        .foregroundColor(SisyphusTheme.textTertiary)
    }

    // MARK: - Add Set Row
    private var addSetRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                switch exerciseType {
                case .weighted:
                    inputField(text: $newWeight, placeholder: "0", suffix: "kg", keyboard: .decimalPad)
                    inputField(text: $newReps, placeholder: "0", suffix: "reps", keyboard: .numberPad)
                case .bodyweight:
                    inputField(text: $newReps, placeholder: "0", suffix: "reps", keyboard: .numberPad)
                case .timed:
                    inputField(text: $newDuration, placeholder: "0", suffix: "sec", keyboard: .numberPad)
                }

                // Add button
                Button(action: addSet) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(SisyphusTheme.accent)
                }
                .disabled(!canAddSet)
            }

            // Options row
            HStack(spacing: 12) {
                Toggle(isOn: $isWarmup) {
                    Text("Warmup")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(SisyphusTheme.textSecondary)
                }
                .toggleStyle(ChipToggleStyle())

                if exerciseType == .weighted {
                    Toggle(isOn: $isDropset) {
                        Text("Dropset")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(SisyphusTheme.textSecondary)
                    }
                    .toggleStyle(ChipToggleStyle())
                }

                Spacer()
            }
        }
    }

    private func inputField(text: Binding<String>, placeholder: String, suffix: String, keyboard: UIKeyboardType) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 16, weight: .medium, design: .monospaced))
            .foregroundColor(SisyphusTheme.textPrimary)
            .multilineTextAlignment(.center)
            .keyboardType(keyboard)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(SisyphusTheme.background)
            .cornerRadius(SisyphusTheme.smallRadius)
            .overlay(
                RoundedRectangle(cornerRadius: SisyphusTheme.smallRadius)
                    .stroke(SisyphusTheme.cardBorder, lineWidth: 1)
            )
            .overlay(
                Text(suffix)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(SisyphusTheme.textTertiary)
                    .padding(.trailing, 8),
                alignment: .trailing
            )
    }

    private var canAddSet: Bool {
        switch exerciseType {
        case .weighted:
            return !newWeight.isEmpty || !newReps.isEmpty
        case .bodyweight:
            return !newReps.isEmpty
        case .timed:
            return !newDuration.isEmpty
        }
    }

    private func addSet() {
        let weight = Double(newWeight)
        let reps = Int(newReps)
        let duration = Int(newDuration)

        onAddSet(weight, reps, duration, newRPE > 0 ? newRPE : nil, isWarmup, isDropset)

        newWeight = ""
        newReps = ""
        newDuration = ""
        isWarmup = false
        isDropset = false
    }

    private func previousSetForNumber(_ setNumber: Int) -> SetLog? {
        previousSets.first { $0.setNumber == setNumber }
    }
}

struct ChipToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack(spacing: 4) {
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }
                configuration.label
            }
            .foregroundColor(configuration.isOn ? .black : SisyphusTheme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(configuration.isOn ? SisyphusTheme.accent : Color.clear)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(configuration.isOn ? SisyphusTheme.accent : SisyphusTheme.cardBorder, lineWidth: 1)
            )
        }
    }
}

#Preview {
    ScrollView {
        ExerciseLogCard(
            exerciseLog: ExerciseLog(
                id: "1",
                sessionId: "1",
                exerciseId: "1",
                exerciseName: "Bench Press",
                muscleGroup: "Chest",
                exerciseType: .weighted,
                sortOrder: 0,
                isSkipped: false,
                createdAt: Date(),
                sets: []
            ),
            previousSets: [],
            onAddSet: { _, _, _, _, _, _ in },
            onDeleteSet: { _ in },
            onSkip: { _ in }
        )
        .padding()
    }
    .background(SisyphusTheme.background)
}
