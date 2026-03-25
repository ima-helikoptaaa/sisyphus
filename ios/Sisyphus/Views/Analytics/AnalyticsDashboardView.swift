import SwiftUI

struct AnalyticsDashboardView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Summary cards
                    summaryGrid

                    // Volume chart
                    VolumeChart(data: viewModel.volumeByDay)

                    // Streak
                    if let summary = viewModel.summary {
                        StreakView(
                            currentStreak: summary.currentStreak ?? 0,
                            longestStreak: summary.longestStreak ?? 0,
                            workoutsByDay: viewModel.volumeByDay
                        )
                    }

                    // Personal Records
                    if !viewModel.personalRecords.isEmpty {
                        PersonalRecordsView(records: viewModel.personalRecords)
                    }

                    // Exercise Progress (if selected)
                    if !viewModel.exerciseProgress.isEmpty {
                        ExerciseProgressChart(data: viewModel.exerciseProgress)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .refreshable {
                await viewModel.loadAllData()
            }

            if viewModel.isLoading && viewModel.summary == nil {
                ProgressView()
                    .tint(SisyphusTheme.accent)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadAllData()
        }
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            SummaryCard(
                title: "Total Workouts",
                value: "\(viewModel.summary?.totalWorkouts ?? 0)",
                icon: "figure.strengthtraining.traditional",
                iconColor: SisyphusTheme.accent
            )
            SummaryCard(
                title: "Current Streak",
                value: "\(viewModel.summary?.currentStreak ?? 0)",
                icon: "flame.fill",
                iconColor: .orange
            )
            SummaryCard(
                title: "This Week",
                value: "\(viewModel.summary?.thisWeekWorkouts ?? 0)",
                icon: "calendar",
                iconColor: .blue
            )
            SummaryCard(
                title: "Total Volume",
                value: formatVolume(viewModel.summary?.totalVolume ?? 0),
                icon: "scalemass.fill",
                iconColor: .purple
            )
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", volume / 1_000_000)
        } else if volume >= 1000 {
            return String(format: "%.1fk", volume / 1000)
        }
        return "\(Int(volume)) kg"
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        SisyphusCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                        .frame(width: 32, height: 32)
                        .background(iconColor.opacity(0.15))
                        .cornerRadius(8)

                    Spacer()
                }

                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(SisyphusTheme.textSecondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsDashboardView()
    }
}
