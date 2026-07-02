import Foundation

final class DailyLogService {
    static let shared = DailyLogService()
    private let api = APIService.shared

    private init() {}

    func upsert(_ request: UpsertDailyLogRequest) async throws -> DailyLog {
        try await api.put(path: "/api/daily-logs", body: request)
    }

    func getToday() async throws -> DailyLog? {
        do {
            let log: DailyLog = try await api.get(path: "/api/daily-logs/today")
            return log
        } catch let error as APIError {
            // Backend returns null for no entry — this becomes a decoding error
            if case .decodingError = error { return nil }
            throw error
        }
    }

    func getLatest() async throws -> DailyLog? {
        do {
            let log: DailyLog = try await api.get(path: "/api/daily-logs/latest")
            return log
        } catch let error as APIError {
            if case .decodingError = error { return nil }
            throw error
        }
    }

    func getHistory(days: Int = 30) async throws -> [DailyLog] {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -days, to: end)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let startStr = formatter.string(from: start)
        let endStr = formatter.string(from: end)
        return try await api.get(path: "/api/daily-logs?startDate=\(startStr)&endDate=\(endStr)")
    }
}
