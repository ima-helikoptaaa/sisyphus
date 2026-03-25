import Foundation

struct WorkoutSplit: Codable, Identifiable {
    let id: String
    let userId: String
    let name: String
    let emoji: String
    let color: String
    let sortOrder: Int
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    var exercises: [Exercise]?
    var exerciseCount: Int?
    var lastWorkoutAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case emoji
        case color
        case sortOrder
        case isActive
        case createdAt
        case updatedAt
        case exercises
        case _count = "_count"
        case lastWorkoutAt
    }

    private struct CountWrapper: Codable {
        let exercises: Int?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        emoji = try container.decode(String.self, forKey: .emoji)
        color = try container.decode(String.self, forKey: .color)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        exercises = try container.decodeIfPresent([Exercise].self, forKey: .exercises)
        lastWorkoutAt = try container.decodeIfPresent(Date.self, forKey: .lastWorkoutAt)

        // Prisma returns { _count: { exercises: N } }
        if let countWrapper = try container.decodeIfPresent(CountWrapper.self, forKey: ._count) {
            exerciseCount = countWrapper.exercises
        } else {
            exerciseCount = nil
        }
    }

    init(
        id: String, userId: String, name: String, emoji: String, color: String,
        sortOrder: Int, isActive: Bool, createdAt: Date, updatedAt: Date,
        exercises: [Exercise]? = nil, exerciseCount: Int? = nil, lastWorkoutAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.emoji = emoji
        self.color = color
        self.sortOrder = sortOrder
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.exercises = exercises
        self.exerciseCount = exerciseCount
        self.lastWorkoutAt = lastWorkoutAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(color, forKey: .color)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(exercises, forKey: .exercises)
        try container.encodeIfPresent(lastWorkoutAt, forKey: .lastWorkoutAt)
    }
}

struct CreateSplitRequest: Codable {
    let name: String
    let emoji: String
    let color: String
}

struct UpdateSplitRequest: Codable {
    let name: String?
    let emoji: String?
    let color: String?
    let sortOrder: Int?
    let isActive: Bool?
}
