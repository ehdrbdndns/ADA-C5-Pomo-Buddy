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
    // Future characters can be added here, e.g., case cat, case hamster
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
    
    @Relationship(deleteRule: .cascade) var workList: [WorkType] = []
    var selectedWorkTypeID: UUID?

    // MARK: - Initialization
    
    init() {
        self.isAutoTimerEnabled = false
        self.language = .systemDefault
        self.selectedCharacter = .default
        self.appearance = .light
        self.workList = []
        self.selectedWorkTypeID = nil
    }
    
    var currentWorkType: WorkType {
        workList.first(where: { $0.id == selectedWorkTypeID }) ?? workList.first!
    }
}
