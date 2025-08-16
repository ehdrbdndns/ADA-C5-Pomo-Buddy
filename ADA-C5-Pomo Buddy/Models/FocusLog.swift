
import Foundation
import SwiftData

@Model
final class FocusLog {
    var date: Date
    var focusDuration: TimeInterval

    init(date: Date, focusDuration: TimeInterval) {
        self.date = date
        self.focusDuration = focusDuration
    }
}
