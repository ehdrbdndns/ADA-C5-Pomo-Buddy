import SwiftUI

enum PageIndex: Int {
    case history = 0
    case timer = 1
    case settings = 2
}

struct ContentView: View {
    // 0: Settings, 1: Timer, 2: History
    @State private var selection: PageIndex = .timer

    var body: some View {
        TabView(selection: $selection) {
            HistoryView()
                .tag(PageIndex.history)
            
            TimerView()
                .tag(PageIndex.timer)
            
            SettingsView()
                .tag(PageIndex.settings)
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Creates the carousel/pager effect
        .font(.custom("Quicksand", size: AppFont.textBase))
        .ignoresSafeArea()
    }
}
