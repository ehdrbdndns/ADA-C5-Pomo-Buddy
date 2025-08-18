//
//  TimerView.swift
//  ADA-C5-Pomo Buddy
//
//  Created by Donggyun Yang on 8/18/25.
//
import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(TimerViewModel.self) var viewModel
    
    var body: some View {
        VStack {
            // coin
            Text("TimerView")
            
            // working Type
            
            // timer
            
            // character
            
            // Button
            // SecondButton
            // PrimaryButton
            
            // explan
            
            // settingState
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.yellow50)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: TimerSettings.self, FocusLog.self, configurations: config)

        let viewModel = TimerViewModel(modelContext: container.mainContext)

        return TimerView()
            .modelContainer(container)
            .environment(viewModel)
    } catch {
        // 에러가 발생하면 에러 메시지를 보여줍니다.
        return Text(error.localizedDescription)
    }
}
