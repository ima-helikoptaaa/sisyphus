import Foundation

struct WorkoutSession: Codable, Identifiable {
    let id: String
    let userId: String
    let splitId: String
    let splitName: String?
    let splitEmoji: String?
    let startedAt: Date
    var completedAt: Date?
    var date: Date?
    var exerciseLogs: [ExerciseLog]?

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case splitId
        case split
        case startedAt
        case completedAt
        case date
        case exerciseLogs
    }

    private struct SplitInfo: Codable {
        let id: String?
        let name: String?
        let emoji: String?
        let color: String?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        splitId = try container.decode(String.self, forKey: .splitId)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
        date = try container.decodeIfPresent(Date.self, forKey: .date)
        exerciseLogs = try container.decodeIfPresent([ExerciseLog].self, forKey: .exerciseLogs)

        // Backend returns nested split: { name, emoji, ... }
        if let splitInfo = try container.decodeIfPresent(SplitInfo.self, forKey: .split) {
            splitName = splitInfo.name
            splitEmoji = splitInfo.emoji
        } else {
            splitName = nil
            splitEmoji = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(splitId, forKey: .splitId)
        try container.encode(startedAt, forKey: .startedAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        try container.encodeIfPresent(date, forKey: .date)
        try container.encodeIfPresent(exerciseLogs, forKey: .exerciseLogs)
    }

    var isActive: Bool {
        completedAt == nil
    }
}

struct CreateSessionRequest: Codable {
    let splitId: String
}

struct CompleteSessionRequest: Codable {
    let completedAt: Date
}
