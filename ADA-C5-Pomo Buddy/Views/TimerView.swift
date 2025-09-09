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
    @State private var isShowingGiveUpAlert: Bool = false
    
    var body: some View {
        @Bindable var viewModel = _viewModel
        let theme = themeManager.currentTheme.theme(for: viewModel.timerState, in: colorScheme)
        
        ZStack {
            VStack(spacing: 0) {
                coinView(theme: theme)
                
                Spacer()
                
                workingTypeView(theme: theme)
                    .padding(.bottom, 12)
                
                timerText()
                    .foregroundStyle(theme.timerViewTheme.timer)
                    .font(.B2)
                    .padding(.bottom, 50)
                
                explainText(theme: theme)
                    .padding(.bottom, 18)
                
                Image(theme.character)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 173)
                
                buttonActionView(theme: theme)
                    .frame(maxWidth: 240)
                    .padding(.top, 60)
                    .padding(.bottom, 72)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
            .background(theme.timerViewTheme.background)
            
            if isShowingWorkTypeEditor {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowingWorkTypeEditor = false
                    }
                
                WorkTypeModalView(isShowing: $isShowingWorkTypeEditor)
                    .padding(.horizontal, 12)
            }
        }
        .alert("timerView_alert_giveUp_title", isPresented: $isShowingGiveUpAlert) {
            Button("timerView_alert_giveUp_confirm", role: .destructive) {
                viewModel.giveUp()
            }
            Button("workTypeListView_alert_delete_cancel", role: .cancel) { }
        } message: {
            Text("timerView_alert_giveUp_message")
        }
    }
}

extension TimerView {
    private func coinView(theme: AppTheme) -> some View {
        HStack {
            Image("Coin")
            Text("\(_viewModel.completedSessionCount)")
                .foregroundStyle(theme.timerViewTheme.coin)
                .font(.M4)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 100)
                .stroke(theme.timerViewTheme.coinBorder, lineWidth: 1)
        )
    }
    
    private func workingTypeView(theme: AppTheme) -> some View {
        Button {
            isShowingWorkTypeEditor = true
        } label: {
            HStack(alignment: .bottom) {
                Text(_viewModel.workType?.name ?? "")
                    .foregroundStyle(theme.timerViewTheme.workingType)
                    .font(.R5)
                
                if _viewModel.timerState == .idle {
                    Image(systemName: "square.and.pencil")
                        .font(.R5)
                        .foregroundStyle(theme.timerViewTheme.pencil)
                }
            }
        }
        .disabled(_viewModel.timerState != .idle)
    }
    
    private func buttonActionView(theme: AppTheme) -> some View {
        HStack {
            switch _viewModel.timerState {
            case .idle:
                Button {
                    _viewModel.start()
                } label: {
                    Text("timerView_button_start")
                }
                .buttonStyle(.primary)
            case .focusing:
                Button {
                    _viewModel.pause()
                } label: {
                    Text("timerView_button_pause")
                }
                .buttonStyle(.secondary)
            case .breaking:
                Button {
                    _viewModel.skipBreak()
                } label: {
                    Text("timerView_button_skipBreak")
                }
                .buttonStyle(.blue)
            case .paused:
                HStack(spacing: 12) {
                    Button {
                        isShowingGiveUpAlert = true 
                    } label: {
                        Text("timerView_button_giveUp")
                    }
                    .buttonStyle(.inactive)
                    
                    Button {
                        _viewModel.resume()
                    } label: {
                        Text("timerView_button_resume")
                    }
                    .buttonStyle(.secondary)
                }
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
            .font(.R4)
    }
    
    private func timerText() -> some View {
        let timeToDisplay: TimeInterval
        
        if _viewModel.timerState == .idle {
            timeToDisplay = _viewModel.workType?.focusDuration ?? 0
        } else {
            timeToDisplay = _viewModel.timeRemaining
        }
        
        return Text(timeToDisplay.formattedTimeString)
    }
}
