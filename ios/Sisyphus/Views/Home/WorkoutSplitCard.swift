import SwiftUI

struct WorkoutSplitCard: View {
    let split: WorkoutSplit

    var body: some View {
        SisyphusCard {
            HStack(spacing: 14) {
                // Emoji icon
                Text(split.emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color(hex: split.color).opacity(0.15))
                    .cornerRadius(SisyphusTheme.smallRadius)

                VStack(alignment: .leading, spacing: 4) {
                    Text(split.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textPrimary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let count = split.exerciseCount {
                            Label("\(count) exercises", systemImage: "list.bullet")
                                .font(.system(size: 13))
                                .foregroundColor(SisyphusTheme.textSecondary)
                        }

                        if let lastWorkout = split.lastWorkoutAt {
                            Text("Last: \(lastWorkout.relativeString)")
                                .font(.system(size: 13))
                                .foregroundColor(SisyphusTheme.textTertiary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(SisyphusTheme.textTertiary)
            }
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    VStack {
        WorkoutSplitCard(
            split: WorkoutSplit(
                id: "1",
                userId: "1",
                name: "Push Day",
                emoji: "\u{1F4AA}",
                color: "C8E64E",
                sortOrder: 0,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date(),
                exercises: nil,
                exerciseCount: 6,
                lastWorkoutAt: Date().addingTimeInterval(-172800)
            )
        )
    }
    .padding()
    .background(SisyphusTheme.background)
}
