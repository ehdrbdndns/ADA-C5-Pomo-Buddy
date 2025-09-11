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
        
        let groupID = "group.com.donggyunyang.ADA-C5-Pomo-Buddy"
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            fatalError("Failed to get container URL")
        }
        let storeURL = containerURL.appendingPathComponent("PomoBuddy.sqlite")
        let modelConfiguration = ModelConfiguration(schema: schema, url: storeURL)
        
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
                newSettings.selectedWorkType = defaultWorkType
                modelContext.insert(newSettings)
            }
        } catch {
            fatalError("Failed to seed initial data: \(error)")
        }
        
        let timerVM = TimerViewModel(modelContext: modelContext)
        let themeM = ThemeManager(modelContext: modelContext)
        
        _timerViewModel = State(initialValue: timerVM)
        _themeManager = State(initialValue: themeM)
        
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        
        requestNotificationPermission()
    }
    
    private func requestNotificationPermission(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    private var preferredColorScheme: ColorScheme? {
        return timerViewModel.isDarkMode ? .dark : .light
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(preferredColorScheme)
                .onAppear {
                    timerViewModel.giveUp()
                }
        }
        .modelContainer(modelContainer)
        .environment(timerViewModel)
        .environment(themeManager)
    }
}
