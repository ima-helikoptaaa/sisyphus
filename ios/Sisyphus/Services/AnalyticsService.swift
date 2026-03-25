import Foundation

final class AnalyticsService {
    static let shared = AnalyticsService()
    private let api = APIService.shared

    private init() {}

    func getSummary() async throws -> AnalyticsSummary {
        try await api.get(path: "/api/analytics/summary")
    }

    func getExerciseProgress(exerciseId: String, days: Int = 90) async throws -> [ExerciseProgressPoint] {
        try await api.get(path: "/api/analytics/exercises/\(exerciseId)/progress?days=\(days)")
    }

    func getPersonalRecords() async throws -> [PersonalRecord] {
        try await api.get(path: "/api/analytics/personal-records")
    }

    func getVolumeByDay(days: Int = 30) async throws -> [DayCount] {
        try await api.get(path: "/api/analytics/volume-by-day?days=\(days)")
    }
}
