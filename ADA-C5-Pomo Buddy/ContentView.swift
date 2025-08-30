import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("navigation_home", systemImage: "house") {
                TimerView()
            }
            
            Tab("navigation_calendar", systemImage: "calendar") {
                HistoryView()
            }
            
            Tab("navigation_settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .font(.custom("Quicksand", size: AppFont.textBase))
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
