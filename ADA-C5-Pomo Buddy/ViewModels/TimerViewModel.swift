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
    
    var accentColor: Color {
        settings?.timerState == .breaking ? .blue1 : .yellow4
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
        
        NotificationManager.shared.cancelAllNotifications()
        
        let endTime = Date().addingTimeInterval(duration)
        
        settings.timerState = .focusing
        settings.sessionEndTime = endTime
        settings.pausedTime = nil
        
        self.timeRemaining = duration
        
        let taskName = workType.name
        LiveActivityManager.shared.startLiveActivity(
            taskName: taskName
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
        
        settings.timerState = .paused
        settings.pausedTime = Date()
        
        NotificationManager.shared.cancelAllNotifications()
        LiveActivityManager.shared.updateLiveActivity(timeRemaining: timeRemaining, timerState: .paused)
    }
    
    func resume() {
        guard let settings = self.settings, settings.timerState == .paused else { return }
        guard let pausedAt = settings.pausedTime, let oldEndTime = settings.sessionEndTime else {
            giveUp()
            return
        }
        
        let pausedDuration = Date().timeIntervalSince(pausedAt)
        let newEndTime = oldEndTime.addingTimeInterval(pausedDuration)
        self.timeRemaining = newEndTime.timeIntervalSince(Date())
        
        settings.sessionEndTime = newEndTime
        settings.pausedTime = nil
        settings.timerState = .focusing
        
        runTimer()
        
        scheduleNotification(for: .focusing, duration: self.timeRemaining)
        LiveActivityManager.shared.updateLiveActivity(timeRemaining: timeRemaining, timerState: .focusing)
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
    
    func logFocusSession(date: Date?, workType: WorkType) {
        let log = FocusLog(date: date ?? .now, focusDuration: workType.focusDuration)
        modelContext.insert(log)
        fetchFocusLogs()
    }
    
    func appWillEnterForeground() {
        synchronizeState()
    }
    
    func prepareForBackground() {
        guard timerState != .paused && timerState != .idle else { return }
        
        stopTimer()
        
        NotificationManager.shared.cancelAllNotifications()
        LiveActivityManager.shared.updateLiveActivity(timeRemaining: timeRemaining, timerState: timerState)
        scheduleNotification(for: timerState, duration: timeRemaining)
    }
    
    func handleTimerCompletion() {
        stopTimer()
        
        guard let settings = settings, let workType = workType else {
            resetToIdle()
            return
        }
        
        
        if let nextStep = TimerStateEngine.calculate(from: settings.timerState, workType: workType, isAutoTimerEnabled: settings.isAutoTimerEnabled) {
            performTransition(using: nextStep, workType: workType)
        } else {
            stopTimer()
            LiveActivityManager.shared.endLiveActivity()
            
            settings.timerState = .idle
            settings.sessionEndTime = nil
            settings.pausedTime = nil
            
            self.timeRemaining = settings.currentWorkType?.focusDuration ?? 0
        }
    }
    
    // MARK: - Private Methods
    private func synchronizeState() {
        guard let settings = self.settings else { return }
        guard timerState != .paused && timerState != .idle else { return }
        guard let workType = self.workType else { return }
        
        fetchFocusLogs()
        
        if let activity = Activity<PomoBuddyActivityAttributes>.activities.first {
            let widgetEndTime = activity.content.state.endTime
            let widgetState = activity.content.state.timerState
            
            settings.timerState = widgetState
            settings.sessionEndTime = widgetEndTime
            
            if Date() < widgetEndTime {
                self.timeRemaining = widgetEndTime.timeIntervalSince(Date())
                runTimer()
                return;
            }
        }
        
        while
            let endTime = settings.sessionEndTime,
            Date() >= endTime
        {
            if settings.timerState == .paused { break }
            
            // Use the state engine to calculate the next step
            if let nextStep = TimerStateEngine.calculate(from: settings.timerState, workType: workType, isAutoTimerEnabled: settings.isAutoTimerEnabled) {
                // If a next step is calculated, apply it
                if nextStep.shouldLogFocusSession {
                    logFocusSession(date: endTime, workType: workType)
                }
                
                settings.timerState = nextStep.nextState
                settings.sessionEndTime = endTime.addingTimeInterval(nextStep.duration)
                
            } else {
                // If calculate returns nil, it means we should go to idle
                settings.timerState = .idle
                settings.sessionEndTime = nil
                break
            }
        }
        
        if let currentEndTime = settings.sessionEndTime, (settings.timerState == .focusing || settings.timerState == .breaking) {
            self.timeRemaining = currentEndTime.timeIntervalSince(Date())
            scheduleNotification(for: settings.timerState, duration: self.timeRemaining)
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
    func performTransition(using nextStep: TimerStateEngine.TransitionResult, workType: WorkType) {
        if nextStep.shouldLogFocusSession {
            logFocusSession(date: .now, workType: workType)
        }
        
        let newEndTime = Date().addingTimeInterval(nextStep.duration)
        
        settings?.timerState = nextStep.nextState
        settings?.sessionEndTime = newEndTime
        self.timeRemaining = nextStep.duration
        
        runTimer()
        
        scheduleNotification(for: nextStep.nextState, duration: nextStep.duration)
        LiveActivityManager.shared.updateLiveActivity(timeRemaining: nextStep.duration, timerState: nextStep.nextState)
    }
    
    func resetToIdle() {
        stopTimer()
        LiveActivityManager.shared.endLiveActivity()
        NotificationManager.shared.cancelAllNotifications()
        
        if let settings = settings {
            settings.timerState = .idle
            settings.sessionEndTime = nil
            settings.pausedTime = nil
        }
        
        self.timeRemaining = settings?.currentWorkType?.focusDuration ?? 0
    }
}

