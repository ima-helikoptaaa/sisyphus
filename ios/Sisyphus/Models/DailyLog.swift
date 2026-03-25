import Foundation

struct DailyLog: Codable, Identifiable {
    let id: String
    let userId: String
    let date: Date
    var weightKg: Double?
    var proteinG: Double?
    var caloriesKcal: Double?
    var waterMl: Double?
    var sleepHours: Double?
    var notes: String?
    let createdAt: Date
    let updatedAt: Date
}

struct UpsertDailyLogRequest: Encodable {
    let date: String
    var weightKg: Double?
    var proteinG: Double?
    var caloriesKcal: Double?
    var waterMl: Double?
    var sleepHours: Double?
    var notes: String?
}
