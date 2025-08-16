
import Foundation
import SwiftData

@Model
final class TimerSettings {
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval

    init(focusDuration: TimeInterval = 25 * 60, breakDuration: TimeInterval = 5 * 60) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
    }
}
