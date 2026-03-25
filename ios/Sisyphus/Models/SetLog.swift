import Foundation

struct SetLog: Codable, Identifiable {
    let id: String
    let exerciseLogId: String
    var setNumber: Int
    var weight: Double?
    var reps: Int?
    var durationSecs: Int?
    var rpe: Double?
    var isWarmup: Bool
    var isDropset: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case exerciseLogId
        case setNumber
        case weight
        case reps
        case durationSecs
        case rpe
        case isWarmup
        case isDropset
        case createdAt
    }

    var volume: Double {
        let w = weight ?? 0
        let r = Double(reps ?? 0)
        return w * r
    }

    var displayText: String {
        var parts: [String] = []
        if let w = weight {
            parts.append("\(w.cleanString)kg")
        }
        if let r = reps {
            parts.append("\(r) reps")
        }
        if let d = durationSecs {
            parts.append("\(d)s")
        }
        return parts.joined(separator: " x ")
    }
}

struct CreateSetLogRequest: Codable {
    let setNumber: Int
    let weight: Double?
    let reps: Int?
    let durationSecs: Int?
    let rpe: Double?
    let isWarmup: Bool
    let isDropset: Bool
}

struct UpdateSetLogRequest: Codable {
    let setNumber: Int?
    let weight: Double?
    let reps: Int?
    let durationSecs: Int?
    let rpe: Double?
    let isWarmup: Bool?
    let isDropset: Bool?
}

extension Double {
    var cleanString: String {
        truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
}
