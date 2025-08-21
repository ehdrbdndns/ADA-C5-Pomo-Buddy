//
//  ADA_C5_Pomo_BuddyApp.swift
//  ADA-C5-Pomo Buddy
//
//  Created by Donggyun Yang on 8/14/25.
//

import SwiftUI
import SwiftData

@main
struct ADA_C5_Pomo_BuddyApp: App {
    let modelContainer: ModelContainer
    @State private var timerViewModel: TimerViewModel
    @State private var themeManager: ThemeManager

    init() {
        let schema = Schema([
            TimerSettings.self,
            FocusLog.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        // Initialize the managers once, using the main context from the container
        let modelContext = modelContainer.mainContext
        let timerVM = TimerViewModel(modelContext: modelContext)
        let themeM = ThemeManager(modelContext: modelContext)
        
        _timerViewModel = State(initialValue: timerVM)
        _themeManager = State(initialValue: themeM)
    }

    private var preferredColorScheme: ColorScheme? {
        return timerViewModel.isDarkMode ? .dark : .light
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(preferredColorScheme)
        }
        .modelContainer(modelContainer)
        .environment(timerViewModel)
        .environment(themeManager)
    }
}
