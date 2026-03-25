import Foundation

enum ExerciseType: String, Codable, CaseIterable, Identifiable {
    case weighted = "weighted"
    case bodyweight = "bodyweight"
    case timed = "timed"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weighted: return "Weighted"
        case .bodyweight: return "Bodyweight"
        case .timed: return "Timed"
        }
    }

    var icon: String {
        switch self {
        case .weighted: return "scalemass.fill"
        case .bodyweight: return "figure.strengthtraining.traditional"
        case .timed: return "timer"
        }
    }

    var subtitle: String {
        switch self {
        case .weighted: return "KG + Reps"
        case .bodyweight: return "Reps only"
        case .timed: return "Seconds"
        }
    }
}

struct Exercise: Codable, Identifiable {
    let id: String
    let splitId: String
    let name: String
    let muscleGroup: String?
    let exerciseType: ExerciseType
    let notes: String?
    let sortOrder: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case splitId
        case name
        case muscleGroup
        case exerciseType
        case notes
        case sortOrder
        case isActive
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        splitId = try container.decode(String.self, forKey: .splitId)
        name = try container.decode(String.self, forKey: .name)
        muscleGroup = try container.decodeIfPresent(String.self, forKey: .muscleGroup)
        exerciseType = try container.decodeIfPresent(ExerciseType.self, forKey: .exerciseType) ?? .weighted
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    init(
        id: String, splitId: String, name: String, muscleGroup: String? = nil,
        exerciseType: ExerciseType = .weighted, notes: String? = nil,
        sortOrder: Int, isActive: Bool, createdAt: Date, updatedAt: Date
    ) {
        self.id = id
        self.splitId = splitId
        self.name = name
        self.muscleGroup = muscleGroup
        self.exerciseType = exerciseType
        self.notes = notes
        self.sortOrder = sortOrder
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct CreateExerciseRequest: Codable {
    let name: String
    let muscleGroup: String?
    let exerciseType: String?
    let notes: String?
}

struct UpdateExerciseRequest: Codable {
    let name: String?
    let muscleGroup: String?
    let exerciseType: String?
    let notes: String?
    let sortOrder: Int?
    let isActive: Bool?
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    case chest = "Chest"
    case back = "Back"
    case shoulders = "Shoulders"
    case biceps = "Biceps"
    case triceps = "Triceps"
    case legs = "Legs"
    case core = "Core"
    case cardio = "Cardio"
    case other = "Other"

    var id: String { rawValue }
}
