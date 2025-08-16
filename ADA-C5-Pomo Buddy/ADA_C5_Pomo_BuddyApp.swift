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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimerSettings.self,
            FocusLog.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
