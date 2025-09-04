import Foundation
import ActivityKit

struct PomoBuddyActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sessionState: String
        var timeRemaining: String
        var endTime: Date
        var characterImageName: String
    }
    
    var taskName: String
}
