import SwiftUI

/// Hamster Theme
struct DefaultTheme: AppThemeProfile {
    // MARK: - Light Mode Themes
    let HAMSTER_IDLE = "hamster-idle"
    let HAMSTER_FOCUSING = "hamster-focus"
    let HAMSTER_BREAKING = "hamster-break"
    
    private func lightTheme(state: TimerState) -> AppTheme {
        var timerBackground = Color.start
        var character = HAMSTER_IDLE
        var coin = Color.yellow3
        var coinBorder = Color.yellow1
        
        switch(state) {
        case .idle:
            timerBackground = Color.start
            character = HAMSTER_IDLE
            coin = Color.yellow3
            coinBorder = Color.yellow1
            break;
        case .focusing:
            timerBackground = Color.focus
            character = HAMSTER_FOCUSING
            coin = Color.yellow3
            coinBorder = Color.yellow1
            break;
        case .breaking:
            timerBackground = Color.rest
            character = HAMSTER_BREAKING
            coin = Color.caption1
            coinBorder = Color.blue1
            break;
        case .paused:
            timerBackground = Color.start
            character = HAMSTER_IDLE
            coin = Color.yellow3
            coinBorder = Color.yellow1
            break;
        }
        
        return AppTheme(
            character: character,
            timerViewTheme: .init(
                coin: coin,
                coinBorder: coinBorder,
                pencil: Color.caption1,
                workingType: Color.caption1,
                timer: Color.title,
                explain: Color.caption1,
                background: timerBackground
            )
        )
    }
    
    private func darkTheme(state: TimerState) -> AppTheme {
        var timerBackground = Color.start
        var character = HAMSTER_IDLE
        var coin = Color.yellow3
        var coinBorder = Color.yellow1
        
        switch(state) {
        case .idle:
            timerBackground = Color.start
            character = HAMSTER_IDLE
            coin = Color.yellow3
            coinBorder = Color.yellow1
            break;
        case .focusing:
            timerBackground = Color.focus
            character = HAMSTER_FOCUSING
            coin = Color.yellow3
            var coinBorder = Color.yellow1
            break;
        case .breaking:
            timerBackground = Color.rest
            character = HAMSTER_BREAKING
            coin = Color.caption1
            var coinBorder = Color.yellow1
            break;
        case .paused:
            timerBackground = Color.start
            character = HAMSTER_IDLE
            coin = Color.yellow3
            var coinBorder = Color.yellow1
            break;
        }
        
        return AppTheme(
            character: character,
            timerViewTheme: .init(
                coin: coin,
                coinBorder: coinBorder,
                pencil: Color.caption1,
                workingType: Color.caption1,
                timer: Color.title,
                explain: Color.caption1,
                background: timerBackground
            )
        )
    }
    
    // MARK: - Public API

    func theme(for state: TimerState, in scheme: ColorScheme) -> AppTheme {
        switch scheme {
        case .light:
            return lightTheme(state: state)
        case .dark:
            return darkTheme(state: state)
        @unknown default:
            return lightTheme(state: state)
        }
    }
}
