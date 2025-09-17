
import Foundation
import ActivityKit

final class LiveActivityManager {
    
    static let shared = LiveActivityManager()
    private init() {}
    
    private var currentActivity: Activity<PomoBuddyActivityAttributes>?
    
    // MARK: - Public Methods
    
    func startLiveActivity(taskName: String, timeRemaining: TimeInterval, characterImageName: String) {
        Task {
            // End all existing Live Activities to ensure only one is active.
            for activity in Activity<PomoBuddyActivityAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            
            // Proceed with starting a new Live Activity.
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
                    pushType: nil
                )
                
                self.currentActivity = activity
                print("Live Activity started: \(activity.id)")
            } catch {
                print("Error starting Live Activity: \(error.localizedDescription)")
            }
        }
    }
    
    func updateLiveActivity(timeRemaining: TimeInterval, timerState: TimerState) {
        let endTime = Date().addingTimeInterval(timeRemaining)
        
        var characterImageName: String = ""
        switch timerState {
        case .focusing:
            characterImageName = "hamster-focus"
        case .breaking:
            characterImageName = "hamster-idle"
        default:
            characterImageName = "hamster-focus"
        }
        
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
            await currentActivity?.end(nil, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }
}
