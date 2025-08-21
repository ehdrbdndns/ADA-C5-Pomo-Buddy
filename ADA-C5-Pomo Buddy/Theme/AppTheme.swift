import SwiftUI

/// A collection of colors for a specific theme state in the app.
struct AppTheme {
    // View Theme
    let timerViewTheme: TimerViewTheme
    
    // Basic Theme
    let background: Color
    let cardBackground: Color
    let buttonTheme: ButtonTheme
}

struct TimerViewTheme {
    let coin: Color
    let pencil: Color
    let workingType: Color
    let timer: Color
    let explain: Color
    let settingState: Color
}

struct ButtonTheme {
    let yellowBackground: Color
    let yellowForground: Color
    
    let greenBackground: Color
    let greenForground: Color
    
    let redBackgorund: Color
    let redForground: Color
}
