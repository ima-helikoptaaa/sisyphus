import Foundation

final class SplitService {
    static let shared = SplitService()
    private let api = APIService.shared

    private init() {}

    func getSplits() async throws -> [WorkoutSplit] {
        try await api.get(path: "/api/splits")
    }

    func getSplit(id: String) async throws -> WorkoutSplit {
        try await api.get(path: "/api/splits/\(id)")
    }

    func createSplit(name: String, emoji: String, color: String) async throws -> WorkoutSplit {
        let body = CreateSplitRequest(name: name, emoji: emoji, color: color)
        return try await api.post(path: "/api/splits", body: body)
    }

    func updateSplit(id: String, update: UpdateSplitRequest) async throws -> WorkoutSplit {
        try await api.patch(path: "/api/splits/\(id)", body: update)
    }

    func deleteSplit(id: String) async throws {
        try await api.delete(path: "/api/splits/\(id)")
    }

    func reorderSplits(ids: [String]) async throws {
        struct SplitOrder: Encodable {
            let id: String
            let sortOrder: Int
        }
        struct ReorderBody: Encodable {
            let splits: [SplitOrder]
        }
        let splits = ids.enumerated().map { SplitOrder(id: $1, sortOrder: $0) }
        let body = ReorderBody(splits: splits)
        let _: [WorkoutSplit] = try await api.patch(path: "/api/splits/reorder", body: body)
    }
}
