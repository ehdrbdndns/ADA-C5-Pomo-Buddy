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
        .accentColor(Color(hex: "#DEAE00"))
        .ignoresSafeArea()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                viewModel.appDidEnterBackground()
            case .active:
                viewModel.appWillEnterForeground()
            default:
                break
            }
        }
    }
}
