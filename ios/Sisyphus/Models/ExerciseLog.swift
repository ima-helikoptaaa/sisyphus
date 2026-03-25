import Foundation

struct ExerciseLog: Codable, Identifiable {
    let id: String
    let sessionId: String
    let exerciseId: String
    let exerciseName: String?
    let muscleGroup: String?
    let exerciseType: ExerciseType
    let sortOrder: Int
    var isSkipped: Bool
    let createdAt: Date
    var sets: [SetLog]?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId
        case exerciseId
        case exercise
        case sortOrder
        case skipped
        case createdAt
        case sets
    }

    private struct ExerciseInfo: Codable {
        let id: String?
        let name: String?
        let muscleGroup: String?
        let exerciseType: ExerciseType?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        sessionId = try container.decode(String.self, forKey: .sessionId)
        exerciseId = try container.decode(String.self, forKey: .exerciseId)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        isSkipped = try container.decodeIfPresent(Bool.self, forKey: .skipped) ?? false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        sets = try container.decodeIfPresent([SetLog].self, forKey: .sets)

        // Backend returns nested exercise: { id, name, muscleGroup, exerciseType }
        if let exerciseInfo = try container.decodeIfPresent(ExerciseInfo.self, forKey: .exercise) {
            exerciseName = exerciseInfo.name
            muscleGroup = exerciseInfo.muscleGroup
            exerciseType = exerciseInfo.exerciseType ?? .weighted
        } else {
            exerciseName = nil
            muscleGroup = nil
            exerciseType = .weighted
        }
    }

    init(
        id: String, sessionId: String, exerciseId: String,
        exerciseName: String? = nil, muscleGroup: String? = nil,
        exerciseType: ExerciseType = .weighted,
        sortOrder: Int, isSkipped: Bool, createdAt: Date, sets: [SetLog]? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.muscleGroup = muscleGroup
        self.exerciseType = exerciseType
        self.sortOrder = sortOrder
        self.isSkipped = isSkipped
        self.createdAt = createdAt
        self.sets = sets
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionId, forKey: .sessionId)
        try container.encode(exerciseId, forKey: .exerciseId)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(isSkipped, forKey: .skipped)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(sets, forKey: .sets)
    }

    var completedSetsCount: Int {
        sets?.filter { !$0.isWarmup }.count ?? 0
    }

    var totalVolume: Double {
        sets?.reduce(0) { total, set in
            let weight = set.weight ?? 0
            let reps = Double(set.reps ?? 0)
            return total + (weight * reps)
        } ?? 0
    }
}

struct CreateExerciseLogRequest: Codable {
    let exerciseId: String
    let sortOrder: Int

    // Backend exercise-log.dto expects snake_case: exercise_id, sort_order
    enum CodingKeys: String, CodingKey {
        case exerciseId = "exercise_id"
        case sortOrder = "sort_order"
    }
}

struct UpdateExerciseLogRequest: Codable {
    let skipped: Bool?
    let sortOrder: Int?

    // Backend exercise-log.dto expects: skipped, sort_order
    enum CodingKeys: String, CodingKey {
        case skipped
        case sortOrder = "sort_order"
    }
}
