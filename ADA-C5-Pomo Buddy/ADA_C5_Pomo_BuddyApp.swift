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
            WorkType.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        let modelContext = modelContainer.mainContext
        
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            let existingSettings = try modelContext.fetch(descriptor)
            
            if existingSettings.isEmpty {
                let newSettings = TimerSettings()
                let defaultWorkType = WorkType(name: "Study", focusDuration: 25 * 60, breakDuration: 5 * 60)
                newSettings.workList.append(defaultWorkType)
                newSettings.selectedWorkTypeID = defaultWorkType.id
                modelContext.insert(newSettings)
            }
        } catch {
            // For a shipping app, you might want to handle this error more gracefully.
            fatalError("Failed to seed initial data: \(error)")
        }
        
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
