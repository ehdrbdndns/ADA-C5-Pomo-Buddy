import SwiftUI

/// The default theme for the app, conforming to the AppThemeProfile protocol.
struct DefaultTheme: AppThemeProfile {

    // MARK: - Shared Theme Components
    
    private static let buttonLightTheme = ButtonTheme(
        yellowBackground: AppColor.yellow400,
        yellowForground: AppColor.yellow900,
        
        greenBackground: AppColor.lime300,
        greenForground: AppColor.lime800,
        
        redBackgorund: AppColor.red400,
        redForground: AppColor.red900,
    )
    
    private static let buttonDarkTheme = ButtonTheme(
        yellowBackground: AppColor.yellow600,
        yellowForground: AppColor.yellow100,
        
        greenBackground: AppColor.lime600,
        greenForground: AppColor.lime100,
        
        redBackgorund: AppColor.red600,
        redForground: AppColor.red100,
    )
    
    // MARK: - Light Mode Themes
    
    private static let idleLight = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber800,
            pencil: AppColor.gray600,
            workingType: AppColor.gray500,
            timer: AppColor.gray700,
            explain: AppColor.yellow700,
            settingState: AppColor.gray500
        ),
        background: AppColor.yellow50,
        cardBackground: AppColor.white,
        buttonTheme: buttonLightTheme
    )

    private static let focusingLight = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber800,
            pencil: AppColor.gray600,
            workingType: AppColor.gray500,
            timer: AppColor.gray700,
            explain: AppColor.amber700,
            settingState: AppColor.gray500
        ),
        background: AppColor.amber50,
        cardBackground: AppColor.white,
        buttonTheme: buttonLightTheme
    )

    private static let breakingLight = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber800,
            pencil: AppColor.gray600,
            workingType: AppColor.gray500,
            timer: AppColor.gray700,
            explain: AppColor.lime700,
            settingState: AppColor.gray500
        ),
        background: AppColor.lime50,
        cardBackground: AppColor.white,
        buttonTheme: buttonLightTheme
    )

    private static let pausedLight = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber800,
            pencil: AppColor.gray600,
            workingType: AppColor.gray500,
            timer: AppColor.gray700,
            explain: AppColor.gray700,
            settingState: AppColor.gray500
        ),
        background: AppColor.gray50,
        cardBackground: AppColor.white,
        buttonTheme: buttonLightTheme
    )

    // MARK: - Dark Mode Themes
    
    private static let idleDark = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber300,
            pencil: AppColor.neutral600,
            workingType: AppColor.neutral400,
            timer: AppColor.zinc50,
            explain: AppColor.yellow300,
            settingState: AppColor.neutral400
        ),
        background: AppColor.DarkModeCustom.backgroundIdle,
        cardBackground: AppColor.white.opacity(0.1),
        buttonTheme: buttonDarkTheme
    )

    private static let focusingDark = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber300,
            pencil: AppColor.neutral600,
            workingType: AppColor.neutral400,
            timer: AppColor.zinc50,
            explain: AppColor.amber300,
            settingState: AppColor.neutral400
        ),
        background: AppColor.DarkModeCustom.backgroundFocus,
        cardBackground: AppColor.white.opacity(0.1),
        buttonTheme: buttonDarkTheme
    )

    private static let breakingDark = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber300,
            pencil: AppColor.neutral600,
            workingType: AppColor.neutral400,
            timer: AppColor.zinc50,
            explain: AppColor.lime300,
            settingState: AppColor.neutral400
        ),
        background: AppColor.DarkModeCustom.backgroundBreak,
        cardBackground: AppColor.white.opacity(0.1),
        buttonTheme: buttonDarkTheme
    )

    private static let pausedDark = AppTheme(
        timerViewTheme: .init(
            coin: AppColor.amber300,
            pencil: AppColor.neutral600,
            workingType: AppColor.neutral400,
            timer: AppColor.zinc50,
            explain: AppColor.yellow300,
            settingState: AppColor.neutral400
        ),
        background: AppColor.DarkModeCustom.backgroundIdle,
        cardBackground: AppColor.white.opacity(0.1),
        buttonTheme: buttonDarkTheme
    )
    
    // MARK: - Public API

    func theme(for state: TimerState, in scheme: ColorScheme) -> AppTheme {
        switch scheme {
        case .light:
            return lightTheme(for: state)
        case .dark:
            return darkTheme(for: state)
        @unknown default:
            return lightTheme(for: state)
        }
    }

    // MARK: - Private Helpers

    private func lightTheme(for state: TimerState) -> AppTheme {
        switch state {
        case .idle: return Self.idleLight
        case .focusing: return Self.focusingLight
        case .breaking: return Self.breakingLight
        case .paused: return Self.pausedLight
        }
    }

    private func darkTheme(for state: TimerState) -> AppTheme {
        switch state {
        case .idle: return Self.idleDark
        case .focusing: return Self.focusingDark
        case .breaking: return Self.breakingDark
        case .paused: return Self.pausedDark
        }
    }
}
