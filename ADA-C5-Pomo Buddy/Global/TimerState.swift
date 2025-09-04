
import Foundation

/// Represents the current state of the timer.
enum TimerState: String, Codable {
    case idle
    case focusing
    case breaking
    case paused
}
