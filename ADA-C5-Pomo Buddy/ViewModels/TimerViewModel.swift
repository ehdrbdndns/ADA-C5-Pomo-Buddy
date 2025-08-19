import Foundation
import SwiftUI
import SwiftData

@Observable
final class TimerViewModel {
    // MARK: - Published Properties
    var timerState: TimerState = .idle
    var timeRemaining: TimeInterval = 0
    var timeString: String = "00:00"
    var focusLogs: [FocusLog] = []

    // MARK: - Computed Properties
    var focusTimeInMinutes: Int {
        Int(settings?.focusDuration ?? 0) / 60
    }

    var breakTimeInMinutes: Int {
        Int(settings?.breakDuration ?? 0) / 60
    }
    
    var completedSessionCount: Int {
        focusLogs.count
    }

    var workType: String {
        get {
            settings?.workType ?? "Pomodoro"
        }
        set {
            settings?.workType = newValue
        }
    }

    // MARK: - Private Properties
    private var timer: Timer?
    private var modelContext: ModelContext
    private var settings: TimerSettings?
    private var prePauseState: TimerState = .idle

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchSettings()
        fetchFocusLogs()
        resetTimer(to: .idle)
    }

    // MARK: - Public Methods

    func start() {
        guard timerState == .idle || timerState == .breaking else { return }
        timeRemaining = settings?.focusDuration ?? 25 * 60
        timerState = .focusing
        runTimer()
    }

    func pause() {
        guard timerState == .focusing || timerState == .breaking else { return }
        prePauseState = timerState
        timer?.invalidate()
        timerState = .paused
    }

    func resume() {
        guard timerState == .paused else { return }
        timerState = prePauseState
        runTimer()
    }
    
    func giveUp() {
        timer?.invalidate()
        resetTimer(to: .idle)
    }

    func skipBreak() {
        timer?.invalidate()
        resetTimer(to: .idle)
    }

    // MARK: - Private Methods

    private func runTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    private func updateTimer() {
        guard timeRemaining > 0 else {
            handleTimerCompletion()
            return
        }
        timeRemaining -= 1
        timeString = formatTime(for: timeRemaining)
    }

    private func handleTimerCompletion() {
        timer?.invalidate()
        switch timerState {
        case .focusing:
            transitionToBreak()
        case .breaking:
            transitionToNextSession()
        default:
            resetTimer(to: .idle)
        }
    }

    private func transitionToBreak() {
        guard let settings = settings else { return }
        
        let log = FocusLog(date: .now, focusDuration: settings.focusDuration)
        modelContext.insert(log)
        fetchFocusLogs() // Refetch to update the count and array
        
        timerState = .breaking
        timeRemaining = settings.breakDuration
        timeString = formatTime(for: timeRemaining)
        runTimer()
    }

    private func transitionToNextSession() {
        guard let settings = settings else { return }
        if settings.isAutoTimerEnabled {
            timerState = .focusing
            timeRemaining = settings.focusDuration
            timeString = formatTime(for: timeRemaining)
            runTimer()
        } else {
            resetTimer(to: .idle)
        }
    }

    private func resetTimer(to state: TimerState) {
        guard let settings = settings else { return }
        self.timerState = state
        self.timeRemaining = settings.focusDuration
        self.timeString = formatTime(for: self.timeRemaining)
    }

    private func fetchSettings() {
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            if let settings = try modelContext.fetch(descriptor).first {
                self.settings = settings
            } else {
                let defaultSettings = TimerSettings()
                modelContext.insert(defaultSettings)
                self.settings = defaultSettings
            }
        } catch {
            fatalError("Failed to fetch settings: \(error)")
        }
    }
    
    private func fetchFocusLogs() {
        do {
            let descriptor = FetchDescriptor<FocusLog>(sortBy: [SortDescriptor(\FocusLog.date, order: .reverse)])
            self.focusLogs = try modelContext.fetch(descriptor)
        } catch {
            fatalError("Failed to fetch focus logs: \(error)")
        }
    }

    private func formatTime(for interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}