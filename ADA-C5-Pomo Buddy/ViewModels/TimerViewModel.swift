import Foundation
import SwiftUI
import SwiftData

@Observable
final class TimerViewModel {
    // MARK: - Published Properties
    var timerState: TimerState = .idle
    var timeRemaining: TimeInterval = 0
    var timeString: String = "00:00"

    // MARK: - Private Properties
    private var timer: Timer?
    private var modelContext: ModelContext
    private var settings: TimerSettings?
    private var prePauseState: TimerState = .idle

    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchSettings()
        resetTimer(to: .idle)
    }

    // MARK: - Public Methods (Actions for the View)

    /// Starts a new focus session from the beginning.
    func start() {
        // This check prevents starting a timer that's already running.
        guard timerState == .idle || timerState == .breaking else { return }
        
        timeRemaining = settings?.focusDuration ?? 25 * 60
        timerState = .focusing
        runTimer()
    }

    /// Pauses the currently running timer.
    func pause() {
        guard timerState == .focusing || timerState == .breaking else { return }
        prePauseState = timerState
        timer?.invalidate()
        timerState = .paused
    }

    /// Resumes the timer from a paused state.
    func resume() {
        guard timerState == .paused else { return }
        timerState = prePauseState
        runTimer()
    }
    
    /// Gives up the current session and resets the timer.
    func giveUp() {
        timer?.invalidate()
        // As per our decision, we do not log the time if the user gives up.
        resetTimer(to: .idle)
    }

    /// Skips the break and resets the timer to the idle state.
    func skipBreak() {
        timer?.invalidate()
        resetTimer(to: .idle)
    }

    // MARK: - Private Timer Control Methods

    /// Invalidates the old timer and creates a new one.
    private func runTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    // MARK: - Private State & Logic Methods

    /// The main heartbeat of the timer, called every second.
    private func updateTimer() {
        guard timeRemaining > 0 else {
            handleTimerCompletion()
            return
        }
        timeRemaining -= 1
        timeString = formatTime(for: timeRemaining)
    }

    /// Handles the logic for when a timer session (focus or break) completes.
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

    /// Transitions the state from focusing to breaking.
    private func transitionToBreak() {
        guard let settings = settings else { return }
        
        let log = FocusLog(date: .now, focusDuration: settings.focusDuration)
        modelContext.insert(log)
        
        timerState = .breaking
        timeRemaining = settings.breakDuration
        timeString = formatTime(for: timeRemaining)
        
        runTimer()
    }

    /// Transitions to the next session after a break, or ends if auto-timer is off.
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

    /// Resets the timer to a specified state, usually idle.
    private func resetTimer(to state: TimerState) {
        guard let settings = settings else { return }
        self.timerState = state
        self.timeRemaining = settings.focusDuration
        self.timeString = formatTime(for: self.timeRemaining)
    }

    // MARK: - Private Data & Formatting Methods

    /// Fetches user settings from SwiftData, or creates them if they don't exist.
    private func fetchSettings() {
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            let fetchedSettings = try modelContext.fetch(descriptor)
            if let settings = fetchedSettings.first {
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

    /// Formats a TimeInterval into a "mm:ss" string.
    private func formatTime(for interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
