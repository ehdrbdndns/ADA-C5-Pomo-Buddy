import Foundation
import SwiftData
import ActivityKit

// This performer handles state transitions when the app is in the background.
// It has no knowledge of the UI and only performs data and system-level actions.
class BackgroundTransitionPerformer: TransitionPerformer {
    
    private let modelContext: ModelContext
    private let liveActivityManager = LiveActivityManager.shared

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func performTransition(using result: TimerStateEngine.TransitionResult, workType: WorkType) {
        guard let settings = fetchSettings() else { return }

        if result.shouldLogFocusSession {
            let log = FocusLog(date: .now, focusDuration: workType.focusDuration)
            modelContext.insert(log)
        }

        let newEndTime = Date().addingTimeInterval(result.duration)
        
        settings.timerState = result.nextState
        settings.sessionEndTime = newEndTime

        liveActivityManager.updateLiveActivity(
            timeRemaining: result.duration,
            timerState: result.nextState,
            characterImageName: result.characterImageName
        )
        
        scheduleNotification(for: result.nextState, duration: result.duration)
    }

    func resetToIdle() {
        guard let settings = fetchSettings() else { return }
        settings.timerState = .idle
        settings.sessionEndTime = nil
        settings.pausedTime = nil
        liveActivityManager.endLiveActivity()
        NotificationManager.shared.cancelAllNotifications()
    }

    // MARK: - Private Helpers
    
    private func fetchSettings() -> TimerSettings? {
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            return try modelContext.fetch(descriptor).first
        } catch {
            print("[BackgroundTransitionPerformer] Failed to fetch settings: \(error)")
            return nil
        }
    }

    private func scheduleNotification(for state: TimerState, duration: TimeInterval) {
        let titleKey = (state == .focusing) ? "notification_focus_title" : "notification_break_title"
        let bodyKey = (state == .focusing) ? "notification_focus_body" : "notification_break_body"

        let title = NSLocalizedString(titleKey, comment: "")
        let body = NSLocalizedString(bodyKey, comment: "")
        
        NotificationManager.shared.scheduleNotification(title: title, body: body, timeInSeconds: duration)
    }
}
