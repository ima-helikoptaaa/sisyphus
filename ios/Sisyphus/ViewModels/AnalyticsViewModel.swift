import Foundation

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var summary: AnalyticsSummary?
    @Published var exerciseProgress: [ExerciseProgressPoint] = []
    @Published var personalRecords: [PersonalRecord] = []
    @Published var volumeByDay: [DayCount] = []
    @Published var selectedExerciseId: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let analyticsService = AnalyticsService.shared

    func loadSummary() async {
        isLoading = true
        errorMessage = nil

        do {
            summary = try await analyticsService.getSummary()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        async let summaryTask = analyticsService.getSummary()
        async let prsTask = analyticsService.getPersonalRecords()
        async let volumeTask = analyticsService.getVolumeByDay(days: 30)

        let fetchedSummary: AnalyticsSummary?
        let fetchedPRs: [PersonalRecord]
        let fetchedVolume: [DayCount]

        do {
            fetchedSummary = try await summaryTask
        } catch {
            fetchedSummary = summary
            errorMessage = error.localizedDescription
        }

        do {
            fetchedPRs = try await prsTask
        } catch {
            fetchedPRs = personalRecords
            if errorMessage == nil { errorMessage = error.localizedDescription }
        }

        do {
            fetchedVolume = try await volumeTask
        } catch {
            fetchedVolume = volumeByDay
            if errorMessage == nil { errorMessage = error.localizedDescription }
        }

        summary = fetchedSummary
        personalRecords = fetchedPRs
        volumeByDay = fetchedVolume
        isLoading = false
    }

    func loadExerciseProgress(exerciseId: String) async {
        selectedExerciseId = exerciseId
        do {
            exerciseProgress = try await analyticsService.getExerciseProgress(exerciseId: exerciseId, days: 90)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadPersonalRecords() async {
        do {
            personalRecords = try await analyticsService.getPersonalRecords()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
