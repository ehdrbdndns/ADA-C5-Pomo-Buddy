
import Foundation
import ActivityKit

final class LiveActivityManager {
    
    private var currentActivity: Activity<PomoBuddyActivityAttributes>?
    
    // MARK: - Public Methods
    
    func startLiveActivity(taskName: String, timeRemaining: TimeInterval, characterImageName: String) {
        let attributes = PomoBuddyActivityAttributes(taskName: taskName)
        
        let endTime = Date().addingTimeInterval(timeRemaining)
        let initialState = PomoBuddyActivityAttributes.ContentState(
            timerState: .focusing,
            endTime: endTime,
            characterImageName: characterImageName,
            timeRemainingString: timeRemaining.formattedTimeString
        )
        
        do {
            let activity = try Activity<PomoBuddyActivityAttributes>.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil)
            
            self.currentActivity = activity
            print("Live Activity started: \(activity.id)")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateLiveActivity(timeRemaining: TimeInterval, timerState: TimerState, characterImageName: String) {
        let endTime = Date().addingTimeInterval(timeRemaining)
        let updatedState = PomoBuddyActivityAttributes.ContentState(
            timerState: timerState,
            endTime: endTime,
            characterImageName: characterImageName,
            timeRemainingString: timeRemaining.formattedTimeString
        )
        
        Task {
            await currentActivity?.update(ActivityContent(state: updatedState, staleDate: nil))
        }
    }
    
    func endLiveActivity() {
        Task {
            await currentActivity?.end(dismissalPolicy: .immediate)
            self.currentActivity = nil
            print("Live Activity ended.")
        }
    }
}
