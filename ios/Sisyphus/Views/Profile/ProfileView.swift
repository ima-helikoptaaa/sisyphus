import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var analyticsViewModel = AnalyticsViewModel()
    @State private var showSignOutConfirmation = false

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Profile header
                    profileHeader

                    // Quick stats
                    quickStats

                    // Sign out
                    SisyphusButton(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", style: .ghost) {
                        showSignOutConfirmation = true
                    }
                    .padding(.top, 16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .alert("Sign Out", isPresented: $showSignOutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .task {
            await analyticsViewModel.loadSummary()
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(SisyphusTheme.accent.opacity(0.15))
                    .frame(width: 88, height: 88)

                if let photoURL = authViewModel.user?.photoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 36))
                            .foregroundColor(SisyphusTheme.accent)
                    }
                    .frame(width: 84, height: 84)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 36))
                        .foregroundColor(SisyphusTheme.accent)
                }
            }

            VStack(spacing: 4) {
                Text(authViewModel.user?.displayName ?? "Athlete")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(SisyphusTheme.textPrimary)

                Text(authViewModel.user?.email ?? "")
                    .font(.system(size: 14))
                    .foregroundColor(SisyphusTheme.textSecondary)

                if let creationDate = authViewModel.user?.metadata.creationDate {
                    Text("Member since \(creationDate.fullDateString)")
                        .font(.system(size: 12))
                        .foregroundColor(SisyphusTheme.textTertiary)
                        .padding(.top, 2)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var quickStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Stats")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(SisyphusTheme.textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ProfileStatCard(
                    title: "Workouts",
                    value: "\(analyticsViewModel.summary?.totalWorkouts ?? 0)",
                    icon: "figure.strengthtraining.traditional"
                )
                ProfileStatCard(
                    title: "Volume",
                    value: formatVolume(analyticsViewModel.summary?.totalVolume ?? 0),
                    icon: "scalemass.fill"
                )
                ProfileStatCard(
                    title: "Best Streak",
                    value: "\(analyticsViewModel.summary?.longestStreak ?? 0)",
                    icon: "flame.fill"
                )
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ProfileStatCard(
                    title: "Total Sets",
                    value: "\(analyticsViewModel.summary?.totalSets ?? 0)",
                    icon: "checkmark.circle"
                )
                ProfileStatCard(
                    title: "Total Reps",
                    value: "\(analyticsViewModel.summary?.totalReps ?? 0)",
                    icon: "arrow.counterclockwise"
                )
                ProfileStatCard(
                    title: "Avg Duration",
                    value: (analyticsViewModel.summary?.averageWorkoutDuration ?? 0).durationFormatted,
                    icon: "clock"
                )
            }
        }
    }

    private func formatVolume(_ volume: Double) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", volume / 1_000_000)
        } else if volume >= 1000 {
            return String(format: "%.0fk", volume / 1000)
        }
        return "\(Int(volume))"
    }
}

struct ProfileStatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        SisyphusCard {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(SisyphusTheme.accent)

                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(SisyphusTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(SisyphusTheme.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environmentObject(AuthViewModel())
    }
}
