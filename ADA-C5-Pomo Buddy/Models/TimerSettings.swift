import SwiftUI
import Foundation
import SwiftData

// MARK: - Supporting Enums

/// Enum to manage language settings in a type-safe way.
enum LanguageSetting: String, Codable {
    case systemDefault
    case korean
    case english
}

/// Enum to manage character types in a type-safe way.
enum CharacterType: String, Codable {
    case `default`
    
    var displayName: LocalizedStringKey {
        switch self {
        case .`default`:
            return "character_name_default"
        }
    }
    
    var imageName: String {
        switch self {
        case .`default`:
            return "hamster-idle"
        }
    }
}

/// Enum to manage the app's appearance mode.
enum AppearanceMode: String, Codable, CaseIterable {
    case light
    case dark

    var localizedStringKey: String {
        switch self {
        case .light:
            return "appearanceMode_light"
        case .dark:
            return "appearanceMode_dark"
        }
    }
}

// MARK: - Main SwiftData Model

@Model
final class TimerSettings {
    // MARK: - Properties
    
    var isAutoTimerEnabled: Bool
    var language: LanguageSetting
    var selectedCharacter: CharacterType
    var appearance: AppearanceMode
    
    var timerState: TimerState
    var sessionEndTime: Date?
    var pausedTime: Date?
    
    @Relationship(deleteRule: .cascade)
    var workList: [WorkType] = []
    
    var selectedWorkType: WorkType?

    // MARK: - Initialization
    
    init() {
        self.isAutoTimerEnabled = false
        self.language = .systemDefault
        self.selectedCharacter = .default
        self.appearance = .light
        self.workList = []
        self.selectedWorkType = nil
        
        self.timerState = .idle
        self.sessionEndTime = nil
        self.pausedTime = nil
    }
    
    var currentWorkType: WorkType? {
        selectedWorkType ?? workList.first
    }
}
