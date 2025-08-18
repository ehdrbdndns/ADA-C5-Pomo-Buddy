
import Foundation
import SwiftUI
import SwiftData

@Observable
final class ThemeManager {
    // The currently active theme profile for the entire app.
    var currentTheme: AppThemeProfile
    
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Set the initial theme based on saved settings
        let settings = ThemeManager.fetchSettings(from: modelContext)
        self.currentTheme = ThemeManager.theme(for: settings.selectedCharacter)
    }
    
    /// Updates the theme based on the character type.
    func updateTheme(for character: CharacterType) {
        // 1. Update the in-memory theme to immediately reflect the change in the UI.
        self.currentTheme = ThemeManager.theme(for: character)
        
        // 2. Fetch the settings object and update its character property.
        let settings = ThemeManager.fetchSettings(from: self.modelContext)
        settings.selectedCharacter = character
        
        // 3. SwiftData will automatically save this change to persistent storage.
    }
    
    /// Returns a theme profile based on a character type.
    private static func theme(for character: CharacterType) -> AppThemeProfile {
        switch character {
        case .default:
            return DefaultTheme()
        // When new characters are added, new cases will be added here.
        // e.g., case .cat: return CatTheme()
        }
    }
    
    /// Fetches user settings from SwiftData, or creates them if they don't exist.
    private static func fetchSettings(from context: ModelContext) -> TimerSettings {
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            if let settings = try context.fetch(descriptor).first {
                return settings
            } else {
                let defaultSettings = TimerSettings()
                context.insert(defaultSettings)
                return defaultSettings
            }
        } catch {
            fatalError("Failed to fetch settings: \(error)")
        }
    }
}
