import Foundation

struct AnalyticsSummary: Codable {
    let totalWorkouts: Int?
    let currentStreak: Int?
    let longestStreak: Int?
    let thisWeekWorkouts: Int?
    let thisMonthWorkouts: Int?
    let totalVolume: Double?
    let totalSets: Int?
    let totalReps: Int?
    let averageWorkoutDuration: Int?
}

struct DayCount: Codable, Identifiable {
    let date: String
    let count: Int

    var id: String { date }
}

struct ExerciseProgressPoint: Codable, Identifiable {
    let date: Date
    let bestSet: SetLog?
    let totalVolume: Double
    let totalSets: Int?

    var id: Date { date }

    var maxWeight: Double { bestSet?.weight ?? 0 }
    var maxReps: Int { bestSet?.reps ?? 0 }
}

struct PersonalRecord: Codable, Identifiable {
    let exerciseId: String
    let exerciseName: String
    let bestWeight: Double?
    let bestWeightDate: Date?
    let bestVolume: Double?
    let bestVolumeDate: Date?
    let bestReps: Int?
    let bestRepsDate: Date?

    var id: String { exerciseId }
}
