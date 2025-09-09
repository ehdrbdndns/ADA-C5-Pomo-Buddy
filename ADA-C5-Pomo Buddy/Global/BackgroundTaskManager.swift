import Foundation
import BackgroundTasks
import SwiftData
import ActivityKit

class BackgroundTaskManager {
    
    static let shared = BackgroundTaskManager()
    private init() {}
    
    let taskIdentifier = "com.donggyun.PomoBuddy.refresh"
    
    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }
    
    func scheduleRefresh(at date: Date) {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = date
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task scheduled at \(date)")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func cancelAll() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        Task {
            let schema = Schema([TimerSettings.self, FocusLog.self, WorkType.self])
            let groupID = "group.com.donggyunyang.ADA-C5-Pomo-Buddy"
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
                task.setTaskCompleted(success: false)
                return
            }
            let storeURL = containerURL.appendingPathComponent("PomoBuddy.sqlite")
            let config = ModelConfiguration(url: storeURL)
            
            do {
                let container = try ModelContainer(for: schema, configurations: [config])
                
                let viewModel = await TimerViewModel(modelContext: container.mainContext)
                viewModel.handleTimerCompletion()
                
                task.setTaskCompleted(success: true)
                
            } catch {
                print("Background task failed to set up SwiftData: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }
}
