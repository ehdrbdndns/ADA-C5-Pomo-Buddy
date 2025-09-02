import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("navigation_home", systemImage: "house") {
                TimerView()
            }
            
            Tab("navigation_settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .accentColor(Color(hex: "#DEAE00"))
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
