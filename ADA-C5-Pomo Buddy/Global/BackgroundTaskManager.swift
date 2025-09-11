import Foundation
import BackgroundTasks
import SwiftData
import ActivityKit

class BackgroundTaskManager {
    
    static let shared = BackgroundTaskManager()
    private init() {}
    
    let taskIdentifier = "com.donggyun.PomoBuddy.refresh"
    
    func register() {
        print("register background task")
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
        print("[BackgroundTask] handleAppRefresh: 시작")
        
        task.expirationHandler = {
            print("[BackgroundTask] handleAppRefresh: 만료 핸들러 호출됨")
            task.setTaskCompleted(success: false)
        }

        Task {
            let schema = Schema([TimerSettings.self, FocusLog.self, WorkType.self])
            let groupID = "group.com.donggyunyang.ADA-C5-Pomo-Buddy"
            
            print("[BackgroundTask] handleAppRefresh: 공유 컨테이너 URL 가져오기 시도")
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
                print("[BackgroundTask] handleAppRefresh: 실패 - 공유 컨테이너 URL을 가져올 수 없음")
                task.setTaskCompleted(success: false)
                return
            }
            print("[BackgroundTask] handleAppRefresh: 성공 - 공유 컨테이너 URL")
            
            let storeURL = containerURL.appendingPathComponent("PomoBuddy.sqlite")
            let config = ModelConfiguration(url: storeURL)
            
            do {
                print("[BackgroundTask] handleAppRefresh: ModelContainer 생성 시도")
                let container = try ModelContainer(for: schema, configurations: [config])
                print("[BackgroundTask] handleAppRefresh: 성공 - ModelContainer 생성 완료")

                // Create a new, private context for this background task
                let newContext = ModelContext(container)

                // Use the new handler to perform the background logic
                print("[BackgroundTask] handleAppRefresh: BackgroundSessionHandler.perform() 호출 직전")
                let handler = BackgroundSessionHandler(modelContext: newContext)
                handler.perform()
                print("[BackgroundTask] handleAppRefresh: BackgroundSessionHandler.perform() 호출 완료")

                // Save any changes made by the handler
                print("[BackgroundTask] handleAppRefresh: newContext.save() 호출 직전")
                try newContext.save()
                print("[BackgroundTask] handleAppRefresh: newContext.save() 호출 완료")

                task.setTaskCompleted(success: true)
                print("[BackgroundTask] handleAppRefresh: 작업 완료 (성공)")

            } catch {
                print("[BackgroundTask] handleAppRefresh: 실패 - SwiftData 설정 중 오류 발생: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }
}
