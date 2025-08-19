import Foundation
import SwiftData

/// Enum to manage language settings in a type-safe way.
enum LanguageSetting: String, Codable {
    case systemDefault
    case korean
    case english
}

/// Enum to manage character types in a type-safe way.
enum CharacterType: String, Codable {
    case `default`
    // Future characters can be added here, e.g., case cat, case hamster
}

@Model
final class TimerSettings {
    var focusDuration: TimeInterval
    var breakDuration: TimeInterval
    var isAutoTimerEnabled: Bool
    var language: LanguageSetting
    var selectedCharacter: CharacterType
    var workType: String

    init(focusDuration: TimeInterval = 25 * 60, 
         breakDuration: TimeInterval = 5 * 60, 
         isAutoTimerEnabled: Bool = false, 
         language: LanguageSetting = .systemDefault,
         selectedCharacter: CharacterType = .default,
         workType: String = "Pomodoro") {
        self.focusDuration = focusDuration
        self.breakDuration = breakDuration
        self.isAutoTimerEnabled = isAutoTimerEnabled
        self.language = language
        self.selectedCharacter = selectedCharacter
        self.workType = workType
    }
}