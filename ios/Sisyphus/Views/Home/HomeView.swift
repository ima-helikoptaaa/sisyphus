import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var workoutViewModel: WorkoutViewModel
    @State private var showingAddSplit = false
    @State private var showingActiveWorkout = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    headerSection

                    // Active Workout Banner
                    if workoutViewModel.isActive {
                        ActiveWorkoutBanner {
                            showingActiveWorkout = true
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // Today's Progress
                    todayProgressSection

                    // Workout Splits
                    splitsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .background(SisyphusTheme.background)

            // FAB - Create new split
            Button(action: { showingAddSplit = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 56, height: 56)
                    .background(SisyphusTheme.accent)
                    .clipShape(Circle())
                    .shadow(color: SisyphusTheme.accent.opacity(0.3), radius: 8, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddSplit) {
            AddSplitSheet { name, emoji, color in
                let splitVM = SplitsViewModel()
                let error = await splitVM.createSplit(name: name, emoji: emoji, color: color)
                if error == nil {
                    await viewModel.loadData()
                }
                return error
            }
            .presentationDetents([.medium])
        }
        .fullScreenCover(isPresented: $showingActiveWorkout) {
            NavigationStack {
                ActiveWorkoutView()
                    .environmentObject(workoutViewModel)
            }
        }
        .task {
            await viewModel.loadData()
            // Restore active workout if one exists on the backend but not in local state
            if !workoutViewModel.isActive, let activeSession = viewModel.activeSession {
                await workoutViewModel.resumeWorkout(session: activeSession)
            }
        }
        .animation(.spring(response: 0.4), value: workoutViewModel.isActive)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(viewModel.greeting)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(SisyphusTheme.textPrimary)

            Text(viewModel.dateString)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SisyphusTheme.textSecondary)
                .tracking(2)
        }
    }

    // MARK: - Today's Progress
    private var todayProgressSection: some View {
        SisyphusCard {
            HStack(spacing: 20) {
                ProgressRing(
                    progress: viewModel.todayWorkoutCount > 0 ? 1.0 : 0.0,
                    lineWidth: 6,
                    size: 64,
                    labelText: "\(viewModel.todayWorkoutCount)"
                )

                VStack(alignment: .leading, spacing: 6) {
                    Text("Today's Workouts")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(SisyphusTheme.textPrimary)

                    HStack(spacing: 16) {
                        StatPill(icon: "flame.fill", value: "\(viewModel.streak)", label: "streak", color: .orange)
                        StatPill(
                            icon: "checkmark.circle.fill",
                            value: "\(viewModel.todayWorkoutCount)",
                            label: "done",
                            color: SisyphusTheme.success
                        )
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Splits
    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Workout Splits")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Spacer()

                NavigationLink {
                    SplitsListView()
                } label: {
                    Text("See All")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SisyphusTheme.accent)
                }
            }

            if viewModel.splits.isEmpty && !viewModel.isLoading {
                EmptyStateView(
                    icon: "dumbbell",
                    title: "No Splits Yet",
                    subtitle: "Create your first workout split to start tracking.",
                    actionTitle: "Create Split"
                ) {
                    showingAddSplit = true
                }
                .frame(height: 200)
            } else {
                ForEach(viewModel.splits) { split in
                    NavigationLink {
                        SplitDetailView(splitId: split.id)
                    } label: {
                        WorkoutSplitCard(split: split)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .tint(SisyphusTheme.accent)
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
    }

}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = SisyphusTheme.accent

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(SisyphusTheme.textPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(SisyphusTheme.textSecondary)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(WorkoutViewModel())
    }
}
