import Foundation
import SwiftUI

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published var currentSession: WorkoutSession?
    @Published var exerciseLogs: [ExerciseLog] = []
    @Published var previousLogs: [String: ExerciseLog] = [:]
    @Published var isActive = false
    @Published var elapsedSeconds: Int = 0
    @Published var restTimerSeconds: Int = 0
    @Published var restTimerTotal: Int = 90
    @Published var isRestTimerRunning = false
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var addingSetForLog: Set<String> = []
    private let sessionService = SessionService.shared
    private var elapsedTimer: Timer?
    private var restTimer: Timer?

    var elapsedTimeFormatted: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var restTimerFormatted: String {
        let minutes = restTimerSeconds / 60
        let seconds = restTimerSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var restTimerProgress: Double {
        guard restTimerTotal > 0 else { return 0 }
        return Double(restTimerSeconds) / Double(restTimerTotal)
    }

    var totalVolume: Double {
        exerciseLogs.reduce(0) { $0 + $1.totalVolume }
    }

    var totalSets: Int {
        exerciseLogs.reduce(0) { $0 + ($1.sets?.count ?? 0) }
    }

    func startWorkout(splitId: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let session = try await sessionService.createSession(splitId: splitId)
            currentSession = session
            exerciseLogs = session.exerciseLogs ?? []
            isActive = true
            isLoading = false
            startElapsedTimer()
            await loadPreviousSession(splitId: splitId, sessionId: session.id)
            triggerHaptic(.medium)
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func resumeWorkout(session: WorkoutSession) async {
        currentSession = session
        exerciseLogs = session.exerciseLogs ?? []
        isActive = true

        if let startedAt = currentSession?.startedAt {
            elapsedSeconds = Int(Date().timeIntervalSince(startedAt))
        }

        startElapsedTimer()

        if let splitId = currentSession?.splitId {
            await loadPreviousSession(splitId: splitId, sessionId: session.id)
        }
    }

    func loadSessionDetail() async {
        guard let sessionId = currentSession?.id else { return }
        do {
            let session = try await sessionService.getSession(id: sessionId)
            currentSession = session
            exerciseLogs = session.exerciseLogs ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadPreviousSession(splitId: String, sessionId: String) async {
        do {
            let previous = try await sessionService.getPreviousSession(
                splitId: splitId, beforeSessionId: sessionId
            )
            var logMap: [String: ExerciseLog] = [:]
            for log in previous.exerciseLogs ?? [] {
                logMap[log.exerciseId] = log
            }
            previousLogs = logMap
        } catch {
            // Previous session data is nice-to-have, not critical
        }
    }

    func addSet(exerciseLogId: String, weight: Double?, reps: Int?, durationSecs: Int? = nil, rpe: Double?, isWarmup: Bool, isDropset: Bool) async {
        guard let sessionId = currentSession?.id else { return }
        guard let logIndex = exerciseLogs.firstIndex(where: { $0.id == exerciseLogId }) else { return }

        // Prevent concurrent adds for the same exercise (double-tap race condition)
        guard !addingSetForLog.contains(exerciseLogId) else { return }
        addingSetForLog.insert(exerciseLogId)
        defer { addingSetForLog.remove(exerciseLogId) }

        let currentSetCount = exerciseLogs[logIndex].sets?.count ?? 0
        let request = CreateSetLogRequest(
            setNumber: currentSetCount + 1,
            weight: weight,
            reps: reps,
            durationSecs: durationSecs,
            rpe: rpe,
            isWarmup: isWarmup,
            isDropset: isDropset
        )

        do {
            let setLog = try await sessionService.createSetLog(
                sessionId: sessionId, exerciseLogId: exerciseLogId, set: request
            )
            if exerciseLogs[logIndex].sets == nil {
                exerciseLogs[logIndex].sets = []
            }
            exerciseLogs[logIndex].sets?.append(setLog)

            triggerHaptic(.light)
            startRestTimer()

            checkForPR(exerciseLogId: exerciseLogId, setLog: setLog)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateSet(exerciseLogId: String, setId: String, update: UpdateSetLogRequest) async {
        guard let sessionId = currentSession?.id else { return }

        do {
            let updated = try await sessionService.updateSetLog(
                sessionId: sessionId, exerciseLogId: exerciseLogId, setId: setId, update: update
            )
            if let logIndex = exerciseLogs.firstIndex(where: { $0.id == exerciseLogId }),
               let setIndex = exerciseLogs[logIndex].sets?.firstIndex(where: { $0.id == setId }) {
                exerciseLogs[logIndex].sets?[setIndex] = updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteSet(exerciseLogId: String, setId: String) async {
        guard let sessionId = currentSession?.id else { return }

        do {
            try await sessionService.deleteSetLog(
                sessionId: sessionId, exerciseLogId: exerciseLogId, setId: setId
            )
            if let logIndex = exerciseLogs.firstIndex(where: { $0.id == exerciseLogId }) {
                exerciseLogs[logIndex].sets?.removeAll { $0.id == setId }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func skipExercise(exerciseLogId: String, skip: Bool) async {
        guard let sessionId = currentSession?.id else { return }

        let update = UpdateExerciseLogRequest(skipped: skip, sortOrder: nil)
        do {
            let updated = try await sessionService.updateExerciseLog(
                sessionId: sessionId, logId: exerciseLogId, update: update
            )
            if let index = exerciseLogs.firstIndex(where: { $0.id == exerciseLogId }) {
                let existingSets = exerciseLogs[index].sets
                exerciseLogs[index] = updated
                if exerciseLogs[index].sets == nil {
                    exerciseLogs[index].sets = existingSets
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func finishWorkout() async -> Bool {
        guard let sessionId = currentSession?.id else { return false }

        do {
            let completed = try await sessionService.completeSession(id: sessionId)
            currentSession = completed
            isActive = false
            elapsedSeconds = 0
            previousLogs = [:]
            stopElapsedTimer()
            stopRestTimer()
            triggerHaptic(.heavy)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func discardWorkout() async -> Bool {
        guard let sessionId = currentSession?.id else { return false }

        do {
            try await sessionService.deleteSession(id: sessionId)
            currentSession = nil
            exerciseLogs = []
            previousLogs = [:]
            isActive = false
            elapsedSeconds = 0
            stopElapsedTimer()
            stopRestTimer()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Elapsed Timer

    private func startElapsedTimer() {
        stopElapsedTimer()
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedSeconds += 1
            }
        }
    }

    private func stopElapsedTimer() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil
    }

    // MARK: - Rest Timer

    func startRestTimer(duration: Int? = nil) {
        stopRestTimer()
        restTimerTotal = duration ?? restTimerTotal
        restTimerSeconds = restTimerTotal
        isRestTimerRunning = true

        restTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                if self.restTimerSeconds > 0 {
                    self.restTimerSeconds -= 1
                } else {
                    self.stopRestTimer()
                    self.triggerHaptic(.heavy)
                }
            }
        }
    }

    func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerRunning = false
        restTimerSeconds = 0
    }

    func setRestDuration(_ seconds: Int) {
        restTimerTotal = seconds
    }

    // MARK: - PR Detection

    private func checkForPR(exerciseLogId: String, setLog: SetLog) {
        guard let log = exerciseLogs.first(where: { $0.id == exerciseLogId }),
              let previousLog = previousLogs[log.exerciseId] else { return }

        let previousBestWeight = previousLog.sets?.compactMap({ $0.weight }).max()
        if let weight = setLog.weight, let prevBest = previousBestWeight, weight > prevBest {
            triggerHaptic(.heavy)
        }
    }

    // MARK: - Haptics

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func previousSetsForExercise(exerciseId: String) -> [SetLog] {
        previousLogs[exerciseId]?.sets ?? []
    }

    deinit {
        elapsedTimer?.invalidate()
        restTimer?.invalidate()
    }
}
