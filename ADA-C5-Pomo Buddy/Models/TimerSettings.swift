import Foundation
import SwiftData

/// Enum to manage language settings in a type-safe way.
enum LanguageSetting: String, Codable {
    case systemDefault
    case korean
    case english
}

@Model
final class TimerSettings {
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval
    var isAutoTimerEnabled: Bool
    var language: LanguageSetting

    init(focusDuration: TimeInterval = 25 * 60, 
         breakDuration: TimeInterval = 5 * 60, 
         isAutoTimerEnabled: Bool = false, 
         language: LanguageSetting = .systemDefault) {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.isAutoTimerEnabled = isAutoTimerEnabled
        self.language = language
    }
}