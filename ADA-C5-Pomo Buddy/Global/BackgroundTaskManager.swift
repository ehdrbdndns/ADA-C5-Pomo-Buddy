import Foundation
import BackgroundTasks
import SwiftData

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
            self.cancelAll()
        }

        do {
            let schema = Schema([
                TimerSettings.self,
                FocusLog.self,
                WorkType.self
            ])
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            Task { @MainActor in
                let viewModel = TimerViewModel(modelContext: container.mainContext)
                
                viewModel.handleTimerCompletion()
                
                print("Background task successfully completed.")
                task.setTaskCompleted(success: true)
            }
        } catch {
            print("Background task failed to set up container: \(error)")
            task.setTaskCompleted(success: false)
        }
    }
}
