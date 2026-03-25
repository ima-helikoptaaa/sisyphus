import Foundation

final class ExerciseService {
    static let shared = ExerciseService()
    private let api = APIService.shared

    private init() {}

    func getExercises(splitId: String) async throws -> [Exercise] {
        try await api.get(path: "/api/splits/\(splitId)/exercises")
    }

    func createExercise(splitId: String, name: String, muscleGroup: String?, exerciseType: String?, notes: String?) async throws -> Exercise {
        let body = CreateExerciseRequest(name: name, muscleGroup: muscleGroup, exerciseType: exerciseType, notes: notes)
        return try await api.post(path: "/api/splits/\(splitId)/exercises", body: body)
    }

    func updateExercise(splitId: String, exerciseId: String, update: UpdateExerciseRequest) async throws -> Exercise {
        try await api.patch(path: "/api/splits/\(splitId)/exercises/\(exerciseId)", body: update)
    }

    func deleteExercise(splitId: String, exerciseId: String) async throws {
        try await api.delete(path: "/api/splits/\(splitId)/exercises/\(exerciseId)")
    }

    func reorderExercises(splitId: String, ids: [String]) async throws {
        struct ExerciseOrder: Encodable {
            let id: String
            let sortOrder: Int
        }
        struct ReorderBody: Encodable {
            let exercises: [ExerciseOrder]
        }
        let exercises = ids.enumerated().map { ExerciseOrder(id: $1, sortOrder: $0) }
        let body = ReorderBody(exercises: exercises)
        let _: [Exercise] = try await api.patch(path: "/api/splits/\(splitId)/exercises/reorder", body: body)
    }
}
