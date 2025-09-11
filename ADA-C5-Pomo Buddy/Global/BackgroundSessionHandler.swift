import Foundation
import SwiftData

// This is the entry point for handling a session completion in the background.
// Its single responsibility is to coordinate the Engine and the Performer.
class BackgroundSessionHandler {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func perform() {
        // 1. Fetch current state
        guard let settings = fetchSettings(),
              let workType = settings.currentWorkType else {
            // Cannot proceed without settings, do nothing.
            return
        }
        
        let performer = BackgroundTransitionPerformer(modelContext: modelContext)

        // 2. Use the Engine to calculate the next state
        if let result = TimerStateEngine.calculate(from: settings.timerState, workType: workType, isAutoTimerEnabled: settings.isAutoTimerEnabled) {
            // 3. Use the Performer to execute the transition
            performer.performTransition(using: result, workType: workType)
        } else {
            // 3a. If engine returns nil, reset to idle
            performer.resetToIdle()
        }
    }

    private func fetchSettings() -> TimerSettings? {
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            return try modelContext.fetch(descriptor).first
        } catch {
            print("[BackgroundSessionHandler] Failed to fetch settings: \(error)")
            return nil
        }
    }
}
