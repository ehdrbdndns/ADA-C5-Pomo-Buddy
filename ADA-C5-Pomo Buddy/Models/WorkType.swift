
import Foundation
import SwiftData

@Model
final class WorkType {
    @Attribute(.unique) var id: UUID
    var name: String
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval
    
    init(id: UUID = UUID(), name: String, focusDuration: TimeInterval, breakDuration: TimeInterval) {
        self.id = id
        self.name = name
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
    }
    
    // MARK: - Computed Properties
    
    var focusDurationInMinutes: Int {
        Int(focusDuration) / 60
    }
    
    var breakDurationInMinutes: Int {
        Int(breakDuration) / 60
    }
}
