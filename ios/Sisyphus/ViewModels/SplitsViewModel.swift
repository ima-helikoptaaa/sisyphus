import Foundation

@MainActor
final class SplitsViewModel: ObservableObject {
    @Published var splits: [WorkoutSplit] = []
    @Published var selectedSplit: WorkoutSplit?
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let splitService = SplitService.shared
    private let exerciseService = ExerciseService.shared

    func loadSplits() async {
        isLoading = true
        errorMessage = nil
        do {
            splits = try await splitService.getSplits()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadSplit(id: String) async {
        isLoading = true
        errorMessage = nil
        do {
            selectedSplit = try await splitService.getSplit(id: id)
            exercises = selectedSplit?.exercises ?? []
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    func loadExercises(splitId: String) async {
        do {
            exercises = try await exerciseService.getExercises(splitId: splitId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createSplit(name: String, emoji: String, color: String) async -> String? {
        do {
            let split = try await splitService.createSplit(name: name, emoji: emoji, color: color)
            splits.append(split)
            return nil
        } catch {
            print("Create split error: \(error)")
            errorMessage = error.localizedDescription
            return error.localizedDescription
        }
    }

    func updateSplit(id: String, update: UpdateSplitRequest) async -> Bool {
        do {
            let updated = try await splitService.updateSplit(id: id, update: update)
            if let index = splits.firstIndex(where: { $0.id == id }) {
                splits[index] = updated
            }
            if selectedSplit?.id == id {
                selectedSplit = updated
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteSplit(id: String) async -> Bool {
        do {
            try await splitService.deleteSplit(id: id)
            splits.removeAll { $0.id == id }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func createExercise(splitId: String, name: String, muscleGroup: String?, exerciseType: String?, notes: String?) async -> Bool {
        do {
            let exercise = try await exerciseService.createExercise(
                splitId: splitId, name: name, muscleGroup: muscleGroup, exerciseType: exerciseType, notes: notes
            )
            exercises.append(exercise)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateExercise(splitId: String, exerciseId: String, update: UpdateExerciseRequest) async -> Bool {
        do {
            let updated = try await exerciseService.updateExercise(splitId: splitId, exerciseId: exerciseId, update: update)
            if let index = exercises.firstIndex(where: { $0.id == exerciseId }) {
                exercises[index] = updated
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteExercise(splitId: String, exerciseId: String) async -> Bool {
        do {
            try await exerciseService.deleteExercise(splitId: splitId, exerciseId: exerciseId)
            exercises.removeAll { $0.id == exerciseId }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func reorderExercises(splitId: String) async {
        let ids = exercises.map { $0.id }
        do {
            try await exerciseService.reorderExercises(splitId: splitId, ids: ids)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func moveExercise(from source: IndexSet, to destination: Int) {
        exercises.move(fromOffsets: source, toOffset: destination)
    }
}
