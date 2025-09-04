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
            self.cancelAll()
        }

        Task {
            do {
                // 1. 현재 실행 중인 Live Activity를 찾습니다.
                guard let activity = Activity<PomoBuddyActivityAttributes>.activities.first else {
                    print("Background Task: No Live Activity found.")
                    task.setTaskCompleted(success: true)
                    return
                }

                let lastState = activity.content.state
                let previousEndTime = lastState.endTime

                // 2. 데이터 저장을 위해 ModelContainer를 설정합니다.
                let schema = Schema([TimerSettings.self, FocusLog.self, WorkType.self])
                let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                let container = try ModelContainer(for: schema, configurations: [config])
                let settings = try await container.mainContext.fetch(FetchDescriptor<TimerSettings>()).first

                var nextStateEnum: TimerState?
                var nextDuration: TimeInterval?
                var characterImageName: String = "hamster-focus"

                // 3. 이전 상태에 따라 다음 상태를 결정합니다.
                switch lastState.timerState {
                case .focusing:
                    if let workType = settings?.currentWorkType {
                        let log = FocusLog(date: .now, focusDuration: workType.focusDuration)
                        await container.mainContext.insert(log)
                    }
                    nextStateEnum = .breaking
                    nextDuration = settings?.currentWorkType?.breakDuration ?? (5 * 60)
                    characterImageName = "hamster-break"

                case .breaking:
                    if settings?.isAutoTimerEnabled == true {
                        nextStateEnum = .focusing
                        nextDuration = settings?.currentWorkType?.focusDuration ?? (25 * 60)
                        characterImageName = "hamster-focus"
                    } else {
                        await activity.end(dismissalPolicy: .immediate)
                        task.setTaskCompleted(success: true)
                        return
                    }
                default:
                    task.setTaskCompleted(success: true)
                    return
                }

                if let nextState = nextStateEnum, let nextDuration = nextDuration {
                    // 4. 오차 없는 다음 종료 시간을 계산하고, 새로운 상태를 만듭니다.
                    let newEndTime = previousEndTime.addingTimeInterval(nextDuration)
                    let newState = PomoBuddyActivityAttributes.ContentState(
                        timerState: nextState,
                        endTime: newEndTime,
                        characterImageName: characterImageName,
                        timeRemainingString: nextDuration.formattedTimeString
                    )
                    
                    // 5. Live Activity를 업데이트하고, 다음 태스크와 알림을 예약합니다.
                    await activity.update(ActivityContent(state: newState, staleDate: nil))
                    scheduleRefresh(at: newEndTime)
                    
                    let title = (nextState == .focusing) ? "Focus session is over!" : "Break is over!"
                    let body = (nextState == .focusing) ? "Good job! Time for a break." : "Let's get back to focus."
                    NotificationManager.shared.scheduleNotification(title: title, body: body, timeInSeconds: nextDuration)
                }
                
                task.setTaskCompleted(success: true)

            } catch {
                print("Background task failed: \(error)")
                task.setTaskCompleted(success: false)
            }
        }
    }
}
