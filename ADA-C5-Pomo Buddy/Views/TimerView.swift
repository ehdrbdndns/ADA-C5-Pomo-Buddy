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
                .foregroundStyle(AppColor.gray700)
                .font(.custom("Menlo-Bold", size: AppFont.text6xl))
            
            /// TODO: 이미지로 전환
            VStack {}
            .frame(width: 100, height: 100)
            .background(.gray)
            .cornerRadius(100)
            .padding(.vertical, 40)
            
            buttonActionView()
                .frame(maxWidth: 240)
                .padding(.bottom, 24)
            
            // explan
            explainText(theme: theme)
            
            Spacer()
            
            // settingState
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
    
    private func coinView(theme: AppTheme) -> some View {
        HStack {
            Image("Coin")
            Text("\(_viewModel.completedSessionCount)")
                .foregroundStyle(theme.coin)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(.white)
        .cornerRadius(100)
        .shadowLG()
    }
    
    private func workingTypeView(theme: AppTheme) -> some View {
        Button {
            isShowingWorkTypeEditor = true
        } label: {
            HStack(alignment: .bottom) {
                Text(_viewModel.workType)
                    .foregroundStyle(theme.workingType)
                    .font(.system(size: AppFont.textBase, weight: .regular))
                
                Image(systemName: "pencil.line")
                    .font(.system(size: 13))
                    .foregroundStyle(AppColor.gray600)
            }
        }
    }
    
    private func buttonActionView() -> some View {
        HStack {
            switch _viewModel.timerState {
            case .focusing:
                HStack(spacing: 12) {
                    Button {
                        print("click giveUp")
                        _viewModel.giveUp()
                    } label: {
                        Text("timerView_button_giveUp")
                    }
                    .buttonStyle(.red)
                    
                    Button {
                        print("click pause")
                        _viewModel.pause()
                    } label: {
                        Text("timerView_button_pause")
                    }
                    .buttonStyle(.yellow)
                }
            case .breaking:
                Button {
                    print("click skipBreak")
                    _viewModel.skipBreak()
                } label: {
                    Text("timerView_button_skipBreak")
                }
                .buttonStyle(.green)
            case .paused:
                Button {
                    print("timerView_button_giveUp")
                    _viewModel.giveUp()
                } label: {
                    Text("timerView_button_giveUp")
                }
                .buttonStyle(.red)
                
                Button {
                    print("Click resume")
                    _viewModel.resume()
                } label: {
                    Text("timerView_button_resume")
                }
                .buttonStyle(.yellow)
            default:
                Button {
                    print("click start")
                    _viewModel.start()
                } label: {
                    Text("timerView_button_start")
                }
                .buttonStyle(.yellow)
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
            .foregroundStyle(theme.explain)
            .font(.system(size: AppFont.textLg, weight: .regular))
    }

    private func settingStateText(theme: AppTheme) -> some View {
        let formatString = NSLocalizedString("timerView_text_settingState", comment: "")
        let settingText = String(format: formatString,
                                 _viewModel.focusTimeInMinutes,
                                 _viewModel.breakTimeInMinutes)
        
        return Text(settingText)
            .font(.system(size: AppFont.textSm, weight: .regular))
            .foregroundStyle(AppColor.gray500)
    }
}

//#Preview {
//    print(0)
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    print(1)
//    let container = try! ModelContainer(for: TimerSettings.self, FocusLog.self, configurations: config)
//    print(2)
//    let viewModel = TimerViewModel(modelContext: container.mainContext)
//    let themeManager = ThemeManager(modelContext: container.mainContext)
//
//    return TimerView()
//            .modelContainer(container)
//            .environment(viewModel)
//            .environment(themeManager)
//}
