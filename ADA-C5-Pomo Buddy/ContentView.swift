import SwiftUI

struct ContentView: View {
    @Environment(TimerViewModel.self) private var viewModel
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        TabView {
            Tab("navigation_home", systemImage: "house") {
                TimerView()
            }
            
            Tab("navigation_settings", systemImage: "gear") {
                SettingsView()
            }
        }
        .accentColor(viewModel.accentColor)
        .ignoresSafeArea()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                viewModel.appWillEnterForeground()
            } else if newPhase == .background {
                viewModel.prepareForBackground()
            }
        }
    }
}
