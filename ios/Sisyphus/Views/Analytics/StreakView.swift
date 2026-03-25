import SwiftUI

struct StreakView: View {
    let currentStreak: Int
    let longestStreak: Int
    let workoutsByDay: [DayCount]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Streak")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(SisyphusTheme.textPrimary)

            SisyphusCard {
                VStack(spacing: 16) {
                    // Streak display
                    HStack(spacing: 24) {
                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.orange)

                                Text("\(currentStreak)")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(SisyphusTheme.textPrimary)
                            }
                            Text("Current Streak")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)
                        }

                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(SisyphusTheme.accent)

                                Text("\(longestStreak)")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(SisyphusTheme.textPrimary)
                            }
                            Text("Best Streak")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(SisyphusTheme.textSecondary)
                        }

                        Spacer()
                    }

                    // Calendar heatmap (last 28 days)
                    Divider()
                        .background(SisyphusTheme.cardBorder)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Last 4 Weeks")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SisyphusTheme.textTertiary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                            // Day labels
                            ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, day in
                                Text(day)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(SisyphusTheme.textTertiary)
                                    .frame(height: 16)
                            }

                            // Heatmap cells for the last 28 days
                            ForEach(Array(last28Days.enumerated()), id: \.offset) { _, dayInfo in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(heatmapColor(count: dayInfo.count))
                                    .frame(height: 24)
                            }
                        }
                    }
                }
            }
        }
    }

    private var last28Days: [DayCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")

        // Build lookup from workout data
        let workoutLookup = Dictionary(uniqueKeysWithValues: workoutsByDay.map { ($0.date, $0.count) })

        // Find the Monday that starts our 4-week grid ending on the current week's Sunday
        // First, find the Monday of the current week
        let weekday = calendar.component(.weekday, from: today) // 1=Sun, 2=Mon...
        let daysFromMonday = (weekday + 5) % 7 // how many days since Monday
        let thisMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!
        let gridStart = calendar.date(byAdding: .day, value: -21, to: thisMonday)! // 3 weeks before this Monday

        return (0..<28).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: gridStart)!
            let dateStr = formatter.string(from: date)
            let count = workoutLookup[dateStr] ?? 0
            return DayCount(date: dateStr, count: count)
        }
    }

    private func heatmapColor(count: Int) -> Color {
        switch count {
        case 0:
            return SisyphusTheme.cardBorder.opacity(0.3)
        case 1:
            return SisyphusTheme.accent.opacity(0.4)
        case 2:
            return SisyphusTheme.accent.opacity(0.7)
        default:
            return SisyphusTheme.accent
        }
    }
}

#Preview {
    StreakView(
        currentStreak: 5,
        longestStreak: 12,
        workoutsByDay: (0..<28).map { DayCount(date: "\($0)", count: Int.random(in: 0...2)) }
    )
    .padding()
    .background(SisyphusTheme.background)
}
