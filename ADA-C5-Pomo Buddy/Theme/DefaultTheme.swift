
import SwiftUI

/// The default theme for the app, conforming to the AppThemeProfile protocol.
struct DefaultTheme: AppThemeProfile {

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
        case .idle: return .idleLight
        case .focusing: return .focusingLight
        case .breaking: return .breakingLight
        case .paused: return .pausedLight
        }
    }

    private func darkTheme(for state: TimerState) -> AppTheme {
        switch state {
        case .idle: return .idleDark
        case .focusing: return .focusingDark
        case .breaking: return .breakingDark
        case .paused: return .pausedDark
        }
    }
}

// MARK: - Theme Definitions

private extension AppTheme {
    // MARK: Light Mode Themes
    static let idleLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.yellow400,
        secondaryAction: nil,
        explan: AppColor.yellow700,
        settingState: AppColor.gray500,
        background: AppColor.yellow50
    )

    static let focusingLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.yellow400,
        secondaryAction: AppColor.red400,
        explan: AppColor.amber700,
        settingState: AppColor.gray500,
        background: AppColor.amber50
    )

    static let breakingLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.lime300,
        secondaryAction: nil,
        explan: AppColor.lime700,
        settingState: AppColor.gray500,
        background: AppColor.lime50
    )

    static let pausedLight = AppTheme(
        workingType: AppColor.gray500,
        timer: AppColor.gray700,
        primaryAction: AppColor.yellow400,
        secondaryAction: AppColor.red400,
        explan: AppColor.gray700,
        settingState: AppColor.gray500,
        background: AppColor.gray50
    )

    // MARK: Dark Mode Themes
    static let idleDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.yellow600,
        secondaryAction: nil,
        explan: AppColor.yellow300,
        settingState: AppColor.neutral400,
        background: AppColor.darkBackgroundIdle
    )

    static let focusingDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.amber600,
        secondaryAction: AppColor.red600,
        explan: AppColor.amber300,
        settingState: AppColor.neutral400,
        background: AppColor.darkBackgroundFocus
    )

    static let breakingDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.lime600,
        secondaryAction: nil,
        explan: AppColor.lime300,
        settingState: AppColor.neutral400,
        background: AppColor.darkBackgroundBreak
    )

    static let pausedDark = AppTheme(
        workingType: AppColor.neutral400,
        timer: AppColor.zinc50,
        primaryAction: AppColor.amber600,
        secondaryAction: AppColor.red600,
        explan: AppColor.yellow300,
        settingState: AppColor.neutral400,
        background: AppColor.darkBackgroundIdle
    )
}
