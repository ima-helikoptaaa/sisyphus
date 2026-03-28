import SwiftUI
import FirebaseCore

@main
struct SisyphusApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var workoutViewModel = WorkoutViewModel()

    init() {
        FirebaseApp.configure()
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                        .environmentObject(workoutViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(.dark)
            .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
                if !isAuthenticated {
                    workoutViewModel.reset()
                }
            }
        }
    }

    private func configureAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color(hex: "0D0D0D"))
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color(hex: "C8E64E"))
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "C8E64E"))
        ]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color(hex: "8E8E93"))
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color(hex: "8E8E93"))
        ]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(Color(hex: "0D0D0D"))
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    }
}

struct MainTabView: View {
    @EnvironmentObject var workoutViewModel: WorkoutViewModel

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Today")
            }

            NavigationStack {
                DailyLogView()
            }
            .tabItem {
                Image(systemName: "heart.text.clipboard")
                Text("Log")
            }

            NavigationStack {
                AnalyticsDashboardView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Stats")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Image(systemName: "gearshape.fill")
                Text("Settings")
            }
        }
        .tint(SisyphusTheme.accent)
    }
}
