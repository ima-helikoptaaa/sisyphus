import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var splits: [WorkoutSplit] = []
    @Published var todaySessions: [WorkoutSession] = []
    @Published var activeSession: WorkoutSession?
    @Published var streak: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let splitService = SplitService.shared
    private let sessionService = SessionService.shared
    private let analyticsService = AnalyticsService.shared

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Good night"
        }
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let day = formatter.string(from: Date()).uppercased()
        formatter.dateFormat = "d MMM"
        let date = formatter.string(from: Date()).uppercased()
        return "\(day) . \(date)"
    }

    var todayWorkoutCount: Int {
        todaySessions.filter { $0.completedAt != nil }.count
    }

    func loadData() async {
        isLoading = true
        errorMessage = nil

        async let splitsTask = splitService.getSplits()
        async let todayTask = sessionService.getTodaySessions()
        async let activeTask = sessionService.getActiveSession()
        async let summaryTask = analyticsService.getSummary()

        do {
            let fetchedSplits = try await splitsTask
            let fetchedToday = try await todayTask
            let fetchedActive = try? await activeTask
            let fetchedSummary = try? await summaryTask

            splits = fetchedSplits
            todaySessions = fetchedToday
            activeSession = fetchedActive
            streak = fetchedSummary?.currentStreak ?? 0
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func startWorkout(splitId: String) async -> WorkoutSession? {
        do {
            let session = try await sessionService.createSession(splitId: splitId)
            activeSession = session
            return session
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func refreshData() async {
        await loadData()
    }
}
