import Foundation
import ActivityKit

struct PomoBuddyActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timerState: TimerState
        var endTime: Date
        var characterImageName: String
        var timeRemainingString: String
    }
    
    var taskName: String
}
