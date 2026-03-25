import Foundation

final class SessionService {
    static let shared = SessionService()
    private let api = APIService.shared

    private init() {}

    func getSessions(limit: Int = 20, offset: Int = 0) async throws -> [WorkoutSession] {
        try await api.get(path: "/api/sessions?limit=\(limit)&offset=\(offset)")
    }

    func getTodaySessions() async throws -> [WorkoutSession] {
        let today = ISO8601DateFormatter.string(from: Date(), timeZone: .current, formatOptions: [.withFullDate])
        return try await api.get(path: "/api/sessions?startDate=\(today)&endDate=\(today)")
    }

    func getSession(id: String) async throws -> WorkoutSession {
        try await api.get(path: "/api/sessions/\(id)")
    }

    func getActiveSession() async throws -> WorkoutSession? {
        let sessions: [WorkoutSession] = try await api.get(path: "/api/sessions/active")
        return sessions.first
    }

    func createSession(splitId: String) async throws -> WorkoutSession {
        let body = CreateSessionRequest(splitId: splitId)
        return try await api.post(path: "/api/sessions", body: body)
    }

    func completeSession(id: String) async throws -> WorkoutSession {
        return try await api.patch(path: "/api/sessions/\(id)/complete")
    }

    func deleteSession(id: String) async throws {
        try await api.delete(path: "/api/sessions/\(id)")
    }

    func getPreviousSession(splitId: String, beforeSessionId: String) async throws -> WorkoutSession {
        try await api.get(path: "/api/sessions/last/\(splitId)?before_session_id=\(beforeSessionId)")
    }

    // Exercise Logs
    func createExerciseLog(sessionId: String, exerciseId: String, sortOrder: Int) async throws -> ExerciseLog {
        let body = CreateExerciseLogRequest(exerciseId: exerciseId, sortOrder: sortOrder)
        return try await api.post(path: "/api/sessions/\(sessionId)/exercises", body: body)
    }

    func updateExerciseLog(sessionId: String, logId: String, update: UpdateExerciseLogRequest) async throws -> ExerciseLog {
        try await api.patch(path: "/api/sessions/\(sessionId)/exercises/\(logId)", body: update)
    }

    // Set Logs
    func createSetLog(sessionId: String, exerciseLogId: String, set: CreateSetLogRequest) async throws -> SetLog {
        try await api.post(path: "/api/sessions/\(sessionId)/exercises/\(exerciseLogId)/sets", body: set)
    }

    func updateSetLog(sessionId: String, exerciseLogId: String, setId: String, update: UpdateSetLogRequest) async throws -> SetLog {
        try await api.patch(
            path: "/api/sessions/\(sessionId)/exercises/\(exerciseLogId)/sets/\(setId)",
            body: update
        )
    }

    func deleteSetLog(sessionId: String, exerciseLogId: String, setId: String) async throws {
        try await api.delete(path: "/api/sessions/\(sessionId)/exercises/\(exerciseLogId)/sets/\(setId)")
    }
}
