
import Foundation
import ActivityKit

final class LiveActivityManager {
    
    private var currentActivity: Activity<PomoBuddyActivityAttributes>?
    
    // MARK: - Public Methods
    
    func startLiveActivity(taskName: String, characterImageName: String, timeString: String, timeRemaining: TimeInterval) {
        let attributes = PomoBuddyActivityAttributes(taskName: taskName, characterImageName: characterImageName)
        
        // ViewModel로부터 받은 timeRemaining으로 endTime을 직접 계산합니다.
        let endTime = Date().addingTimeInterval(timeRemaining)
        let initialState = PomoBuddyActivityAttributes.ContentState(
            sessionState: "Focus",
            timeRemaining: timeString,
            endTime: endTime
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
    
    func updateLiveActivity(timeString: String, sessionState: String, timeRemaining: TimeInterval) {
        // ViewModel로부터 받은 timeRemaining으로 endTime을 직접 계산합니다.
        let endTime = Date().addingTimeInterval(timeRemaining)
        let updatedState = PomoBuddyActivityAttributes.ContentState(
            sessionState: sessionState,
            timeRemaining: timeString,
            endTime: endTime
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
