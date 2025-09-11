import Foundation
import SwiftUI
import SwiftData
import ActivityKit
import Combine

@Observable
final class TimerViewModel {
    // MARK: - Published Properties
    var timeRemaining: TimeInterval = 0
    var focusLogs: [FocusLog] = []
    var settings: TimerSettings?
    
    // MARK: - Private Properties
    private var timer: AnyCancellable?
    private var modelContext: ModelContext
    private let liveActivityManager = LiveActivityManager.shared
    
    // MARK: - Computed Properties
    var focusTimeInMinutes: Int {
        Int((settings?.currentWorkType?.focusDuration ?? 0) / 60)
    }
    
    var breakTimeInMinutes: Int {
        Int((settings?.currentWorkType?.breakDuration ?? 0) / 60)
    }
    
    var completedSessionCount: Int {
        focusLogs.count
    }
    
    var workType: WorkType? {
        get {
            settings?.currentWorkType ?? nil
        }
        set {
            settings?.selectedWorkType = newValue
        }
    }
    
    var workTypeList: [WorkType] {
        get {
            settings?.workList ?? []
        }
        set {
            if var workList = settings?.workList {
                workList.append(contentsOf: newValue)
            }
        }
    }
    
    var isAutoTimerEnabled: Bool {
        get {
            settings?.isAutoTimerEnabled ?? false
        }
        set {
            settings?.isAutoTimerEnabled = newValue
        }
    }
    
    var isDarkMode: Bool {
        get {
            appearanceMode == .dark
        }
        set {
            appearanceMode = newValue ? .dark : .light
        }
    }
    
    var timerState: TimerState {
        get {
            settings?.timerState ?? .idle
        }
        set {
            settings?.timerState = newValue
        }
    }
    
    private var appearanceMode: AppearanceMode {
        get {
            settings?.appearance ?? .light
        }
        set {
            settings?.appearance = newValue
        }
    }
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchSettings()
        fetchFocusLogs()
    }
    
    // MARK: - Public Methods
    func start() {
        guard let settings = self.settings,
              (settings.timerState == .idle || settings.timerState == .breaking) else { return }
        
        guard let workType = self.workType else { return }
        guard let duration = settings.currentWorkType?.focusDuration else { return }
        
        cancelAllScheduledTasks()
        
        let endTime = Date().addingTimeInterval(duration)
        
        settings.timerState = .focusing
        settings.sessionEndTime = endTime
        settings.pausedTime = nil
        
        self.timeRemaining = duration
        
        liveActivityManager.startLiveActivity(
            taskName: workType.name
            , timeRemaining: timeRemaining
            , characterImageName: "hamster-focus"
        )
        scheduleNotification(for: .focusing, duration: duration)
        runTimer()
    }
    
    func pause() {
        guard let settings = self.settings else { return }
        guard (settings.timerState == .focusing || settings.timerState == .breaking) else { return }
        
        stopTimer()
        cancelAllScheduledTasks()
        
        settings.timerState = .paused
        settings.pausedTime = Date()
        
        liveActivityManager.updateLiveActivity(
            timeRemaining: self.timeRemaining
            , timerState: .paused
            , characterImageName: "hamster-focus"
        )
    }
    
    func resume() {
        guard let settings = self.settings,
              settings.timerState == .paused else { return }
        
        guard let pausedAt = settings.pausedTime,
              let oldEndTime = settings.sessionEndTime else {
            giveUp()
            return
        }
        
        let pausedDuration = Date().timeIntervalSince(pausedAt)
        let newEndTime = oldEndTime.addingTimeInterval(pausedDuration)
        
        settings.sessionEndTime = newEndTime
        settings.pausedTime = nil
        settings.timerState = .focusing // 항상 .focusing으로 복원
        
        self.timeRemaining = newEndTime.timeIntervalSince(Date())
        
        liveActivityManager.updateLiveActivity(
            timeRemaining: self.timeRemaining
            , timerState: .focusing
            , characterImageName: "hamster-focus"
        )
        
        scheduleNotification(for: .focusing, duration: self.timeRemaining)
        runTimer()
    }
    
    func giveUp() {
        resetToIdle()
    }
    
    func skipBreak() {
        resetToIdle()
    }
    
    func deleteWorkType(_ workType: WorkType) {
        guard let settings = settings, settings.workList.count > 1 else { return }
        
        let isDeletingSelected = settings.selectedWorkType?.id == workType.id
        
        settings.workList.removeAll { $0.id == workType.id }
        
        if isDeletingSelected {
            settings.selectedWorkType = settings.workList.first
        }
        
        modelContext.delete(workType)
    }
    
    func addWorkType(name: String, focusMinutes: Int, breakMinutes: Int) {
        guard let settings = settings, settings.workList.count < 6 else { return }
        
        let newWorkType = WorkType(
            name: name,
            focusDuration: TimeInterval(focusMinutes * 60),
            breakDuration: TimeInterval(breakMinutes * 60)
        )
        
        modelContext.insert(newWorkType)
        settings.workList.append(newWorkType)
        settings.selectedWorkType = newWorkType
    }
    
    func logFocusSession(workType: WorkType) {
        let log = FocusLog(date: .now, focusDuration: workType.focusDuration)
        modelContext.insert(log)
        fetchFocusLogs()
    }
    
    func appWillEnterForeground() {
        synchronizeState()
    }
    
    func prepareForBackground() {
        stopTimer()
        
        guard timerState == .focusing || timerState == .breaking else { return }
        guard let endTime = settings?.sessionEndTime else { return }
        
        let remainingTime = endTime.timeIntervalSince(Date())
        if remainingTime > 0 {
            BackgroundTaskManager.shared.cancelAll()
            scheduleBackgroundTask(duration: remainingTime)
        }
    }
    
    func handleTimerCompletion() {
        stopTimer()
        
        guard let settings = settings, let workType = workType else {
            resetToIdle()
            return
        }
        
        if let result = TimerStateEngine.calculate(from: settings.timerState, workType: workType, isAutoTimerEnabled: settings.isAutoTimerEnabled) {
            performTransition(using: result, workType: workType)
        } else {
            resetToIdle()
        }
    }
    
    // MARK: - Private Methods
    
    private func synchronizeState() {
        fetchFocusLogs()
        
        if let activity = Activity<PomoBuddyActivityAttributes>.activities.first {
            let widgetEndTime = activity.content.state.endTime
            let widgetState = activity.content.state.timerState
            
            self.settings?.timerState = widgetState
            self.settings?.sessionEndTime = widgetEndTime
            
            if widgetState == .paused {
                if let pausedAt = self.settings?.pausedTime {
                    self.timeRemaining = widgetEndTime.timeIntervalSince(pausedAt)
                }
                
            } else if Date() < widgetEndTime {
                self.timeRemaining = widgetEndTime.timeIntervalSince(Date())
                runTimer()
                
            } else {
                handleTimerCompletion()
            }
            return
        }
        
        guard let settings = self.settings else { return }
        
        while let endTime = settings.sessionEndTime, Date() >= endTime {
            if settings.timerState == .paused { break }
            
            let lastState = settings.timerState
            
            if lastState == .focusing {
                let breakDuration = settings.currentWorkType?.breakDuration ?? 0
                settings.timerState = .breaking
                settings.sessionEndTime = endTime.addingTimeInterval(breakDuration)
                let log = FocusLog(date: endTime, focusDuration: settings.currentWorkType?.focusDuration ?? 0)
                modelContext.insert(log)
                
            } else if lastState == .breaking {
                if settings.isAutoTimerEnabled {
                    let focusDuration = settings.currentWorkType?.focusDuration ?? 0
                    settings.timerState = .focusing
                    settings.sessionEndTime = endTime.addingTimeInterval(focusDuration)
                } else {
                    settings.timerState = .idle
                    settings.sessionEndTime = nil
                    break
                }
            } else {
                break
            }
        }
        
        if let currentEndTime = settings.sessionEndTime, (settings.timerState == .focusing || settings.timerState == .breaking) {
            self.timeRemaining = currentEndTime.timeIntervalSince(Date())
            runTimer()
        } else {
            giveUp()
        }
    }
    
    private func scheduleNotification(for state: TimerState, duration: TimeInterval) {
        let titleKey = (state == .focusing) ? "notification_focus_title" : "notification_break_title"
        let bodyKey = (state == .focusing) ? "notification_focus_body" : "notification_break_body"
        
        let title = NSLocalizedString(titleKey, comment: "")
        let body = NSLocalizedString(bodyKey, comment: "")
        
        NotificationManager.shared.scheduleNotification(title: title, body: body, timeInSeconds: duration)
    }
    
    private func scheduleBackgroundTask(duration: TimeInterval) {
        BackgroundTaskManager.shared.scheduleRefresh(at: Date().addingTimeInterval(duration))
    }
    
    private func cancelAllScheduledTasks() {
        NotificationManager.shared.cancelAllNotifications()
        BackgroundTaskManager.shared.cancelAll()
    }
    
    private func runTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
        timer?.cancel()
        
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer()
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func updateTimer() {
        guard let endTime = settings?.sessionEndTime else {
            giveUp()
            return
        }
        
        let newRemaining = endTime.timeIntervalSince(Date())
        
        guard newRemaining > 0 else {
            self.timeRemaining = 0
            handleTimerCompletion()
            return
        }
        
        self.timeRemaining = newRemaining
    }
    
    private func fetchSettings() {
        do {
            let descriptor = FetchDescriptor<TimerSettings>()
            if let settings = try modelContext.fetch(descriptor).first {
                self.settings = settings
            } else {
                let defaultSettings = TimerSettings()
                modelContext.insert(defaultSettings)
                self.settings = defaultSettings
            }
        } catch {
            fatalError("Failed to fetch settings: \(error)")
        }
    }
    
    private func fetchFocusLogs() {
        do {
            let descriptor = FetchDescriptor<FocusLog>(sortBy: [SortDescriptor(\FocusLog.date, order: .reverse)])
            self.focusLogs = try modelContext.fetch(descriptor)
        } catch {
            fatalError("Failed to fetch focus logs: \(error)")
        }
    }
}

// MARK: - TransitionPerformer Conformance
extension TimerViewModel: TransitionPerformer {
    func performTransition(using result: TimerStateEngine.TransitionResult, workType: WorkType) {
        if result.shouldLogFocusSession {
            logFocusSession(workType: workType)
        }
        
        let newEndTime = Date().addingTimeInterval(result.duration)
        
        settings?.timerState = result.nextState
        settings?.sessionEndTime = newEndTime
        
        self.timeRemaining = result.duration
        
        liveActivityManager.updateLiveActivity(
            timeRemaining: result.duration,
            timerState: result.nextState,
            characterImageName: result.characterImageName
        )
        
        scheduleNotification(for: result.nextState, duration: result.duration)
        runTimer()
    }
    
    func resetToIdle() {
        stopTimer()
        liveActivityManager.endLiveActivity()
        cancelAllScheduledTasks()
        
        if let settings = settings {
            settings.timerState = .idle
            settings.sessionEndTime = nil
            settings.pausedTime = nil
        }
        
        self.timeRemaining = settings?.currentWorkType?.focusDuration ?? 0
    }
}
