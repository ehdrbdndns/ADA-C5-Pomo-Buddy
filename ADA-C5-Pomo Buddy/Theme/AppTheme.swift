import SwiftUI

/// A collection of colors for a specific theme state in the app.
struct AppTheme {
    // Character
    let character: String
    
    // View Theme
    let timerViewTheme: TimerViewTheme
}

struct TimerViewTheme {
    let coin: Color
    let pencil: Color
    let workingType: Color
    let timer: Color
    let explain: Color
    let background: Color
}

struct ButtonTheme {
    let primaryBackground: Color
    let primaryForground: Color
    
    let secondaryBackground: Color
    let secondaryForground: Color
    
    let inActiveBackground: Color
    let inActiveForground: Color
}
