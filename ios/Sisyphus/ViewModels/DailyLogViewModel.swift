import Foundation

@MainActor
final class DailyLogViewModel: ObservableObject {
    @Published var todayLog: DailyLog?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    // Input fields
    @Published var weightInput: String = ""
    @Published var proteinInput: String = ""
    @Published var caloriesInput: String = ""
    @Published var waterInput: String = ""
    @Published var sleepInput: String = ""
    @Published var notesInput: String = ""

    private let service = DailyLogService.shared

    var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    func loadToday() async {
        isLoading = true
        do {
            todayLog = try await service.getToday()
            populateFromLog()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func save() async {
        isSaving = true
        errorMessage = nil

        let request = UpsertDailyLogRequest(
            date: todayDateString,
            weightKg: Double(weightInput),
            proteinG: Double(proteinInput),
            caloriesKcal: Double(caloriesInput),
            waterMl: Double(waterInput),
            sleepHours: Double(sleepInput),
            notes: notesInput.isEmpty ? nil : notesInput
        )

        do {
            todayLog = try await service.upsert(request)
            populateFromLog()
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    private func populateFromLog() {
        guard let log = todayLog else { return }
        weightInput = log.weightKg.map { formatNumber($0) } ?? ""
        proteinInput = log.proteinG.map { formatNumber($0) } ?? ""
        caloriesInput = log.caloriesKcal.map { formatNumber($0) } ?? ""
        waterInput = log.waterMl.map { formatNumber($0) } ?? ""
        sleepInput = log.sleepHours.map { formatNumber($0) } ?? ""
        notesInput = log.notes ?? ""
    }

    private func formatNumber(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
