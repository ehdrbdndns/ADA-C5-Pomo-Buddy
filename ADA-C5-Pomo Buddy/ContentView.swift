import SwiftUI

struct ContentView: View {
    // 0: Settings, 1: Timer, 2: History
    @State private var selection: Int = 1

    var body: some View {
        TabView(selection: $selection) {
            SettingsView()
                .tag(0)

            TimerView()
                .tag(1)

            HistoryView()
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never)) // Creates the carousel/pager effect
        .ignoresSafeArea()
    }
}
