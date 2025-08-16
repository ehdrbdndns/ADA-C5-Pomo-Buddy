import SwiftUI

/// A protocol that defines the requirements for a complete theme in the app.
/// It ensures that any conforming theme can provide a specific `AppTheme`
/// for any combination of app state and color scheme.
protocol AppThemeProfile {
    /// Returns the appropriate theme for a given app state and color scheme.
    /// - Parameters:
    ///   - state: The current state of the app (e.g., idle, focusing).
    ///   - scheme: The current color scheme (light or dark).
    /// - Returns: A complete `AppTheme` struct with the correct colors.
    func theme(for state: AppState, in scheme: ColorScheme) -> AppTheme
}