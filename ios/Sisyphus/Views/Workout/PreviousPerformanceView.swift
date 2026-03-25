import SwiftUI

struct PreviousPerformanceView: View {
    let previousSets: [SetLog]
    var exerciseType: ExerciseType = .weighted

    private var workingSets: [SetLog] {
        previousSets.filter { !$0.isWarmup }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 11))
                    .foregroundColor(SisyphusTheme.textTertiary)

                Text("Last Session")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SisyphusTheme.textTertiary)

                Spacer()

                Text(summaryText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(SisyphusTheme.textSecondary)
            }

            // Compact set summary row
            HStack(spacing: 6) {
                ForEach(Array(previousSets.prefix(8).enumerated()), id: \.offset) { _, set in
                    PreviousSetChip(setLog: set, exerciseType: exerciseType)
                }

                if previousSets.count > 8 {
                    Text("+\(previousSets.count - 8)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(SisyphusTheme.textTertiary)
                }

                Spacer(minLength: 0)
            }
        }
        .padding(10)
        .background(SisyphusTheme.background.opacity(0.5))
        .cornerRadius(SisyphusTheme.smallRadius)
    }

    private var summaryText: String {
        let sets = workingSets
        guard !sets.isEmpty else { return "" }

        switch exerciseType {
        case .weighted:
            let bestWeight = sets.compactMap(\.weight).max() ?? 0
            let totalReps = sets.compactMap(\.reps).reduce(0, +)
            return "\(bestWeight.cleanString)kg · \(totalReps) reps"
        case .bodyweight:
            let totalReps = sets.compactMap(\.reps).reduce(0, +)
            return "\(sets.count) sets · \(totalReps) reps"
        case .timed:
            let totalSecs = sets.compactMap(\.durationSecs).reduce(0, +)
            return "\(sets.count) sets · \(formatDuration(totalSecs))"
        }
    }

    private func formatDuration(_ seconds: Int) -> String {
        if seconds >= 60 {
            return "\(seconds / 60)m\(seconds % 60)s"
        }
        return "\(seconds)s"
    }
}

struct PreviousSetChip: View {
    let setLog: SetLog
    var exerciseType: ExerciseType = .weighted

    var body: some View {
        HStack(spacing: 2) {
            if setLog.isWarmup {
                Text("W")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(SisyphusTheme.warning)
            }

            switch exerciseType {
            case .weighted:
                Text("\(setLog.weight?.cleanString ?? "0")×\(setLog.reps ?? 0)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(setLog.isWarmup ? SisyphusTheme.textTertiary.opacity(0.6) : SisyphusTheme.textTertiary)
            case .bodyweight:
                Text("\(setLog.reps ?? 0)")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(setLog.isWarmup ? SisyphusTheme.textTertiary.opacity(0.6) : SisyphusTheme.textTertiary)
            case .timed:
                Text("\(setLog.durationSecs ?? 0)s")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(setLog.isWarmup ? SisyphusTheme.textTertiary.opacity(0.6) : SisyphusTheme.textTertiary)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(SisyphusTheme.cardBorder.opacity(setLog.isWarmup ? 0.15 : 0.3))
        .cornerRadius(4)
    }
}

#Preview {
    PreviousPerformanceView(
        previousSets: [
            SetLog(id: "1", exerciseLogId: "1", setNumber: 1, weight: 60, reps: 12, durationSecs: nil, rpe: nil, isWarmup: true, isDropset: false, createdAt: Date()),
            SetLog(id: "2", exerciseLogId: "1", setNumber: 2, weight: 65, reps: 10, durationSecs: nil, rpe: nil, isWarmup: false, isDropset: false, createdAt: Date()),
            SetLog(id: "3", exerciseLogId: "1", setNumber: 3, weight: 65, reps: 8, durationSecs: nil, rpe: nil, isWarmup: false, isDropset: false, createdAt: Date()),
            SetLog(id: "4", exerciseLogId: "1", setNumber: 4, weight: 65, reps: 8, durationSecs: nil, rpe: nil, isWarmup: false, isDropset: false, createdAt: Date()),
        ]
    )
    .padding()
    .background(SisyphusTheme.cardBackground)
}
