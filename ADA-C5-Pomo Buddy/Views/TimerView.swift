//
//  TimerView.swift
//  ADA-C5-Pomo Buddy
//
//  Created by Donggyun Yang on 8/18/25.
//
import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(TimerViewModel.self) private var _viewModel
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var isShowingWorkTypeEditor: Bool = false
    
    var body: some View {
        @Bindable var viewModel = _viewModel
        let theme = themeManager.currentTheme.theme(for: viewModel.timerState, in: colorScheme)
        
        VStack(spacing: 0) {
            // coin
            coinView(theme: theme)
            
            Spacer()
            
            workingTypeView(theme: theme)
                .padding(.bottom, 12)
            
            Text(viewModel.timeString)
                .foregroundStyle(theme.timerViewTheme.timer)
                .font(.custom("Menlo-Bold", size: AppFont.text6xl))
            
            /// TODO: 이미지로 전환
            VStack {}
            .frame(width: 100, height: 100)
            .background(.gray)
            .cornerRadius(100)
            .padding(.vertical, 40)
            
            buttonActionView(theme: theme)
                .frame(maxWidth: 240)
                .padding(.bottom, 24)
            
            explainText(theme: theme)
            
            Spacer()
            
            settingStateText(theme: theme)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 40)
        .background(theme.background)
        .sheet(isPresented: $isShowingWorkTypeEditor) {
            WorkTypeEditView(workType: $viewModel.workType)
        }
    }
}

extension TimerView {
    private func coinView(theme: AppTheme) -> some View {
        HStack {
            Image("Coin")
            Text("\(_viewModel.completedSessionCount)")
                .foregroundStyle(theme.timerViewTheme.coin)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(theme.cardBackground)
        .cornerRadius(100)
        .shadowLG()
    }
    
    private func workingTypeView(theme: AppTheme) -> some View {
        Button {
            isShowingWorkTypeEditor = true
        } label: {
            HStack(alignment: .bottom) {
                Text(_viewModel.workType)
                    .foregroundStyle(theme.timerViewTheme.workingType)
                    .font(.system(size: AppFont.textBase, weight: .regular))
                
                Image(systemName: "pencil.line")
                    .font(.system(size: 13))
                    .foregroundStyle(theme.timerViewTheme.pencil)
            }
        }
    }
    
    private func buttonActionView(theme: AppTheme) -> some View {
        HStack {
            switch _viewModel.timerState {
            case .focusing:
                HStack(spacing: 12) {
                    Button {
                        _viewModel.giveUp()
                    } label: {
                        Text("timerView_button_giveUp")
                    }
                    .buttonStyle(
                        CustomButtonStyle(
                            backgroundColor: theme.buttonTheme.redBackgorund,
                            foregroundColor: theme.buttonTheme.redForground
                        )
                    )
                    
                    Button {
                        _viewModel.pause()
                    } label: {
                        Text("timerView_button_pause")
                    }
                    .buttonStyle(
                        CustomButtonStyle(
                            backgroundColor: theme.buttonTheme.yellowBackground,
                            foregroundColor: theme.buttonTheme.yellowForground
                        )
                    )
                }
            case .breaking:
                Button {
                    _viewModel.skipBreak()
                } label: {
                    Text("timerView_button_skipBreak")
                }
                .buttonStyle(
                    CustomButtonStyle(
                        backgroundColor: theme.buttonTheme.greenBackground,
                        foregroundColor: theme.buttonTheme.greenForground
                    )
                )
            case .paused:
                Button {
                    _viewModel.giveUp()
                } label: {
                    Text("timerView_button_giveUp")
                }
                .buttonStyle(
                    CustomButtonStyle(
                        backgroundColor: theme.buttonTheme.redBackgorund,
                        foregroundColor: theme.buttonTheme.redForground
                    )
                )
                
                Button {
                    _viewModel.resume()
                } label: {
                    Text("timerView_button_resume")
                }
                .buttonStyle(
                    CustomButtonStyle(
                        backgroundColor: theme.buttonTheme.yellowBackground,
                        foregroundColor: theme.buttonTheme.yellowForground
                    )
                )
            default:
                Button {
                    _viewModel.start()
                } label: {
                    Text("timerView_button_start")
                }
                .buttonStyle(
                    CustomButtonStyle(
                        backgroundColor: theme.buttonTheme.yellowBackground,
                        foregroundColor: theme.buttonTheme.yellowForground
                    )
                )
            }
        }
    }
    
    private func explainText(theme: AppTheme) -> some View {
        let explainText: LocalizedStringKey = {
            switch _viewModel.timerState {
            case .breaking:
                return "timerView_text_explanationBreaking"
            case .focusing:
                return "timerView_text_explanationFocusing"
            case .paused:
                return "timerView_text_explanationPaused"
            default:
                return "timerView_text_explanationIdle"
            }
        }();
        
        return Text(explainText)
            .foregroundStyle(theme.timerViewTheme.explain)
            .font(.system(size: AppFont.textLg, weight: .regular))
    }

    private func settingStateText(theme: AppTheme) -> some View {
        let formatString = NSLocalizedString("timerView_text_settingState", comment: "")
        let settingText = String(format: formatString,
                                 _viewModel.focusTimeInMinutes,
                                 _viewModel.breakTimeInMinutes)
        
        return Text(settingText)
            .font(.system(size: AppFont.textSm, weight: .regular))
            .foregroundStyle(theme.timerViewTheme.settingState)
    }
}
