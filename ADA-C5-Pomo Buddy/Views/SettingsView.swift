import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(TimerViewModel.self) var _viewModel: TimerViewModel
    @Environment(ThemeManager.self) var themeManager: ThemeManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        @Bindable var viewModel = _viewModel
        let theme = themeManager.currentTheme.theme(for: .idle, in: colorScheme)
        
        ZStack {
            theme.background.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    customTitle(theme: theme)
                    timerSettingsSection(
                        focusDuration: $viewModel.focusDurationMinutes,
                        breakDuration: $viewModel.breakDurationMinutes,
                        isAuto: $viewModel.isAutoTimerEnabled,
                        theme: theme
                    )
                    appearanceSettingsSection(
                        isDarkMode: $viewModel.isDarkMode,
                        theme: theme
                    )
                    quickSettingsSection(viewModel: viewModel, theme: theme)
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - Sub-views
private extension SettingsView {
    
    func customTitle(theme: AppTheme) -> some View {
        Text("settingsView_title")
            .font(.system(size: AppFont.text2xl, weight: .bold))
            .foregroundColor(theme.timerViewTheme.timer)
            .padding(.top, 20)
    }
    
    func timerSettingsSection(focusDuration: Binding<Int>, breakDuration: Binding<Int>, isAuto: Binding<Bool>, theme: AppTheme) -> some View {
        Section(
            header: Text("settingsView_section_timerSettings")
                .font(.system(size: AppFont.textXl, weight: .bold))
                .foregroundColor(theme.timerViewTheme.timer)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            VStack(spacing: 20) {
                Stepper(value: focusDuration, in: 5...90, step: 1) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settingsView_timer_focusDuration")
                                .font(.system(size: AppFont.textBase))
                                .foregroundColor(theme.timerViewTheme.explain)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(focusDuration.wrappedValue)")
                                    .font(.system(size: AppFont.text6xl, weight: .bold))
                                    .foregroundColor(theme.timerViewTheme.timer)
                                Text("min")
                                    .font(.system(size: AppFont.textLg, weight: .semibold))
                                    .foregroundColor(theme.timerViewTheme.explain)
                            }
                        }
                        Spacer()
                    }
                }
                
                Divider()
                
                Stepper(value: breakDuration, in: 1...30, step: 1) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("settingsView_timer_breakDuration")
                                .font(.system(size: AppFont.textBase))
                                .foregroundColor(theme.timerViewTheme.explain)
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(breakDuration.wrappedValue)")
                                    .font(.system(size: AppFont.text6xl, weight: .bold))
                                    .foregroundColor(theme.timerViewTheme.timer)
                                Text("min")
                                    .font(.system(size: AppFont.textLg, weight: .semibold))
                                    .foregroundColor(theme.timerViewTheme.explain)
                            }
                        }
                        Spacer()
                    }
                }
                
                Divider()
                
                Toggle(isOn: isAuto) {
                    Text("settingsView_timer_autoStart")
                        .font(.system(size: AppFont.textBase))
                }
                .foregroundColor(theme.timerViewTheme.explain)
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadowLG()
        }
        .padding(.horizontal)
    }
    
    func appearanceSettingsSection(isDarkMode: Binding<Bool>, theme: AppTheme) -> some View {
        Section(
            header: Text("settingsView_section_appearance")
                .font(.system(size: AppFont.textXl, weight: .bold))
                .foregroundColor(theme.timerViewTheme.timer)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            Toggle(isOn: isDarkMode) {
                Text("appearanceMode_darkMode_toggle")
                    .font(.system(size: AppFont.textBase))
            }
            .foregroundColor(theme.timerViewTheme.explain)
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadowLG()
        }
        .padding(.horizontal)
    }
    
    func quickSettingsSection(viewModel: TimerViewModel, theme: AppTheme) -> some View {
        Section(
            header: Text("settingsView_section_quickSettings")
                .font(.system(size: AppFont.textXl, weight: .bold))
                .foregroundColor(theme.timerViewTheme.timer)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
        ) {
            VStack(spacing: 12) {
                Button(action: {
                    viewModel.applyQuickSetting(focus: 25, breakTime: 5)
                }) {
                    VStack {
                        Text("settingsView_quickSettings_classic")
                        Text("settingsView_quickSettings_classic_detail")
                            .font(.system(size: AppFont.textSm))
                            .opacity(0.8)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.yellow)
                
                Button(action: {
                    viewModel.applyQuickSetting(focus: 45, breakTime: 15)
                }) {
                    VStack {
                        Text("settingsView_quickSettings_extended")
                        Text("settingsView_quickSettings_extended_detail")
                            .font(.system(size: AppFont.textSm))
                            .opacity(0.8)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.red)
                
                Button(action: {
                    viewModel.applyQuickSetting(focus: 15, breakTime: 3)
                }) {
                    VStack {
                        Text("settingsView_quickSettings_quick")
                        Text("settingsView_quickSettings_quick_detail")
                            .font(.system(size: AppFont.textSm))
                            .opacity(0.8)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.green)
            }
            .padding()
            .background(theme.cardBackground)
            .cornerRadius(12)
            .shadowLG()
        }
        .padding(.horizontal)
    }
}