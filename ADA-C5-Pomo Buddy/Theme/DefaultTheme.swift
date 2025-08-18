import SwiftUI

/// The default theme for the app, conforming to the AppThemeProfile protocol.
struct DefaultTheme: AppThemeProfile {

    // MARK: - Theme Definitions
    
    // MARK: Light Mode Themes
    private static let idleLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.yellow400,
        secondaryAction: nil,
        explan: AppColor.yellow700,
        settingState: AppColor.gray500,
        background: AppColor.yellow50,
        primaryButtonText: AppColor.yellow900
    )

    private static let focusingLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.yellow400,
        secondaryAction: AppColor.red400,
        explan: AppColor.amber700,
        settingState: AppColor.gray500,
        background: AppColor.amber50,
        primaryButtonText: AppColor.yellow900
    )

    private static let breakingLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.lime300,
        secondaryAction: nil,
        explan: AppColor.lime700,
        settingState: AppColor.gray500,
        background: AppColor.lime50,
        primaryButtonText: AppColor.lime800
    )

    private static let pausedLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.yellow400,
        secondaryAction: AppColor.red400,
        explan: AppColor.gray700,
        settingState: AppColor.gray500,
        background: AppColor.gray50,
        primaryButtonText: AppColor.yellow900
    )

    // MARK: Dark Mode Themes
    private static let idleDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.yellow600,
        secondaryAction: nil,
        explan: AppColor.yellow300,
        settingState: AppColor.neutral400,
        background: AppColor.DarkModeCustom.backgroundIdle,
        primaryButtonText: AppColor.yellow100
    )

    private static let focusingDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.amber600,
        secondaryAction: AppColor.red600,
        explan: AppColor.amber300,
        settingState: AppColor.neutral400,
        background: AppColor.DarkModeCustom.backgroundFocus,
        primaryButtonText: AppColor.amber100
    )

    private static let breakingDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.lime600,
        secondaryAction: nil,
        explan: AppColor.lime300,
        settingState: AppColor.neutral400,
        background: AppColor.DarkModeCustom.backgroundBreak,
        primaryButtonText: AppColor.lime100
    )

    private static let pausedDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.amber600,
        secondaryAction: AppColor.red600,
        explan: AppColor.yellow300,
        settingState: AppColor.neutral400,
        background: AppColor.DarkModeCustom.backgroundIdle,
        primaryButtonText: AppColor.amber100
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
