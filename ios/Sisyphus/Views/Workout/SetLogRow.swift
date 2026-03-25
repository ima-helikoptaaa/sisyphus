import SwiftUI

struct SetLogRow: View {
    let setLog: SetLog
    let previousSet: SetLog?
    var exerciseType: ExerciseType = .weighted
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Set number with badge
            HStack(spacing: 4) {
                if setLog.isWarmup {
                    Text("W")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(SisyphusTheme.warning)
                } else if setLog.isDropset {
                    Text("D")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.purple)
                } else {
                    Text("\(setLog.setNumber)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textPrimary)
                }
            }
            .frame(width: 40, alignment: .leading)

            // Previous
            previousColumn
                .frame(width: 80, alignment: .leading)

            // Current values
            switch exerciseType {
            case .weighted:
                Text(setLog.weight?.cleanString ?? "-")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(weightColor)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(setLog.reps.map { "\($0)" } ?? "-")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(repsColor)
                    .frame(maxWidth: .infinity, alignment: .center)

            case .bodyweight:
                Text(setLog.reps.map { "\($0)" } ?? "-")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(repsColorBodyweight)
                    .frame(maxWidth: .infinity, alignment: .center)

            case .timed:
                Text(setLog.durationSecs.map { formatDuration($0) } ?? "-")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                    .foregroundColor(durationColor)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            // PR/improvement indicator
            ZStack {
                if isImprovement {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(SisyphusTheme.success)
                        .accessibilityLabel("Improvement over previous set")
                } else if isPR {
                    Text("PR")
                        .font(.system(size: 10, weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(SisyphusTheme.accent)
                        .cornerRadius(3)
                        .accessibilityLabel("Personal record")
                }
            }
            .frame(width: 32)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete Set", systemImage: "trash")
            }
        }
    }

    @ViewBuilder
    private var previousColumn: some View {
        if let prev = previousSet {
            switch exerciseType {
            case .weighted:
                Text("\(prev.weight?.cleanString ?? "-")x\(prev.reps ?? 0)")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(SisyphusTheme.textTertiary)
            case .bodyweight:
                Text("\(prev.reps ?? 0) reps")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(SisyphusTheme.textTertiary)
            case .timed:
                Text(prev.durationSecs.map { formatDuration($0) } ?? "-")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(SisyphusTheme.textTertiary)
            }
        } else {
            Text("-")
                .font(.system(size: 13))
                .foregroundColor(SisyphusTheme.textTertiary)
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            return "\(seconds / 60)m\(seconds % 60)s"
        }
        return "\(seconds)s"
    }

    // MARK: - Comparison logic

    private var isImprovement: Bool {
        guard let prev = previousSet else { return false }
        switch exerciseType {
        case .weighted:
            let currentWeight = setLog.weight ?? 0
            let prevWeight = prev.weight ?? 0
            let currentReps = setLog.reps ?? 0
            let prevReps = prev.reps ?? 0
            return (currentWeight > prevWeight) || (currentWeight == prevWeight && currentReps > prevReps)
        case .bodyweight:
            let currentReps = setLog.reps ?? 0
            let prevReps = prev.reps ?? 0
            return currentReps > prevReps
        case .timed:
            let currentDur = setLog.durationSecs ?? 0
            let prevDur = prev.durationSecs ?? 0
            return currentDur > prevDur
        }
    }

    private var isPR: Bool {
        guard let prev = previousSet else { return false }
        switch exerciseType {
        case .weighted:
            let currentWeight = setLog.weight ?? 0
            let prevWeight = prev.weight ?? 0
            return currentWeight > prevWeight && currentWeight > 0
        case .bodyweight:
            let currentReps = setLog.reps ?? 0
            let prevReps = prev.reps ?? 0
            return currentReps > prevReps && currentReps > 0
        case .timed:
            let currentDur = setLog.durationSecs ?? 0
            let prevDur = prev.durationSecs ?? 0
            return currentDur > prevDur && currentDur > 0
        }
    }

    private var weightColor: Color {
        guard let prev = previousSet, let currentWeight = setLog.weight, let prevWeight = prev.weight else {
            return SisyphusTheme.textPrimary
        }
        if currentWeight > prevWeight { return SisyphusTheme.success }
        if currentWeight < prevWeight { return SisyphusTheme.destructive }
        return SisyphusTheme.textPrimary
    }

    private var repsColor: Color {
        guard let prev = previousSet, let currentReps = setLog.reps, let prevReps = prev.reps,
              setLog.weight == prev.weight else {
            return SisyphusTheme.textPrimary
        }
        if currentReps > prevReps { return SisyphusTheme.success }
        if currentReps < prevReps { return SisyphusTheme.destructive }
        return SisyphusTheme.textPrimary
    }

    private var repsColorBodyweight: Color {
        guard let prev = previousSet, let currentReps = setLog.reps, let prevReps = prev.reps else {
            return SisyphusTheme.textPrimary
        }
        if currentReps > prevReps { return SisyphusTheme.success }
        if currentReps < prevReps { return SisyphusTheme.destructive }
        return SisyphusTheme.textPrimary
    }

    private var durationColor: Color {
        guard let prev = previousSet, let currentDur = setLog.durationSecs, let prevDur = prev.durationSecs else {
            return SisyphusTheme.textPrimary
        }
        if currentDur > prevDur { return SisyphusTheme.success }
        if currentDur < prevDur { return SisyphusTheme.destructive }
        return SisyphusTheme.textPrimary
    }
}

#Preview {
    VStack {
        SetLogRow(
            setLog: SetLog(
                id: "1", exerciseLogId: "1", setNumber: 1,
                weight: 80, reps: 10, durationSecs: nil, rpe: 8,
                isWarmup: false, isDropset: false, createdAt: Date()
            ),
            previousSet: SetLog(
                id: "2", exerciseLogId: "2", setNumber: 1,
                weight: 75, reps: 10, durationSecs: nil, rpe: 8,
                isWarmup: false, isDropset: false, createdAt: Date()
            ),
            onDelete: {}
        )
    }
    .padding()
    .background(SisyphusTheme.cardBackground)
}
