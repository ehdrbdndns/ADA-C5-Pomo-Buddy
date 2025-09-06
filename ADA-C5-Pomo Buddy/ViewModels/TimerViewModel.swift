import Foundation
import SwiftUI
import SwiftData
import ActivityKit

@Observable
final class TimerViewModel {
    // MARK: - Published Properties
    var timerState: TimerState = .idle
    var timeRemaining: TimeInterval = 0
    var focusLogs: [FocusLog] = []
    var settings: TimerSettings?
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var modelContext: ModelContext
    private var prePauseState: TimerState = .idle
    private let liveActivityManager = LiveActivityManager()
    private var timeWhenMovedToBackground: Date?
    
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
        resetTimer(to: .idle)
    }
    
    // MARK: - Public Methods
    func start() {
        guard timerState == .idle || timerState == .breaking else { return }
        cancelAllScheduledTasks()
        
        timerState = .focusing
        timeRemaining = settings?.currentWorkType?.focusDuration ?? (25 * 60)
        
        liveActivityManager.startLiveActivity(taskName: workType?.name ?? "Focus", timeRemaining: timeRemaining, characterImageName: "hamster-focus")
        scheduleSession(for: .focusing, duration: timeRemaining)
        runTimer()
    }
    
    func pause() {
        guard timerState == .focusing || timerState == .breaking else { return }
        prePauseState = timerState
        stopTimer()
        timerState = .paused
        cancelAllScheduledTasks()
        
        let characterImageName = (prePauseState == .focusing) ? "hamster-focus" : "hamster-break"
        liveActivityManager.updateLiveActivity(timeRemaining: timeRemaining, timerState: .paused, characterImageName: characterImageName)
    }
    
    func resume() {
        guard timerState == .paused else { return }
        timerState = prePauseState
        
        let characterImageName = (timerState == .focusing) ? "hamster-focus" : "hamster-break"
        liveActivityManager.updateLiveActivity(timeRemaining: timeRemaining, timerState: timerState, characterImageName: characterImageName)
        
        scheduleSession(for: timerState, duration: timeRemaining)
        runTimer()
    }
    
    func giveUp() {
        stopTimer()
        liveActivityManager.endLiveActivity()
        cancelAllScheduledTasks()
        resetTimer(to: .idle)
    }
    
    func skipBreak() {
        stopTimer()
        liveActivityManager.endLiveActivity()
        cancelAllScheduledTasks()
        resetTimer(to: .idle)
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
    
    func appWillEnterForeground() {
        guard let timeWhenMovedToBackground = self.timeWhenMovedToBackground else { return }
        
        guard let activity = Activity<PomoBuddyActivityAttributes>.activities.first else { return }
        let latestState = activity.content.state
        
        let newTimeRemaining = latestState.endTime.timeIntervalSinceNow
        
        if newTimeRemaining <= 0 {
            handleTimerCompletion()
        } else {
            self.timerState = latestState.timerState
            self.timeRemaining = newTimeRemaining
            runTimer()
        }
        
        self.timeWhenMovedToBackground = nil
    }
    
    // MARK: - Private Methods
    
    private func scheduleSession(for state: TimerState, duration: TimeInterval) {
        let title = (state == .focusing) ? "Focus session is over!" : "Break is over!"
        let body = (state == .focusing) ? "Good job! Time for a break." : "Let's get back to focus."
        
        NotificationManager.shared.scheduleNotification(title: title, body: body, timeInSeconds: duration)
        BackgroundTaskManager.shared.scheduleRefresh(at: Date().addingTimeInterval(duration))
    }
    
    private func cancelAllScheduledTasks() {
        NotificationManager.shared.cancelAllNotifications()
        BackgroundTaskManager.shared.cancelAll()
    }
    
    private func runTimer() {
        UIApplication.shared.isIdleTimerDisabled = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            handleTimerCompletion()
            return
        }
        timeRemaining -= 1
    }
    
    func handleTimerCompletion() {
        stopTimer()
        cancelAllScheduledTasks()

        switch timerState {
        case .focusing:
            transitionToBreak()
        case .breaking:
            transitionToNextSession()
        default:
            resetTimer(to: .idle)
        }
    }
    
    private func transitionToBreak() {
        guard let settings = settings else { return }
        
        let log = FocusLog(date: .now, focusDuration: settings.currentWorkType?.focusDuration ?? (25 * 60))
        modelContext.insert(log)
        fetchFocusLogs()
        
        timerState = .breaking
        timeRemaining = settings.currentWorkType?.breakDuration ?? (5 * 60)
        
        liveActivityManager.updateLiveActivity(timeRemaining: timeRemaining, timerState: .breaking, characterImageName: "hamster-break")
        scheduleSession(for: .breaking, duration: timeRemaining)
        runTimer()
    }
    
    private func transitionToNextSession() {
        guard let settings = settings else { return }
        if settings.isAutoTimerEnabled {
            timerState = .focusing
            timeRemaining = settings.currentWorkType?.focusDuration ?? (25 * 60)
            
            liveActivityManager.updateLiveActivity(timeRemaining: timeRemaining, timerState: .focusing, characterImageName: "hamster-focus")
            scheduleSession(for: .focusing, duration: timeRemaining)
            runTimer()
        } else {
            liveActivityManager.endLiveActivity()
            resetTimer(to: .idle)
        }
    }
    
    private func resetTimer(to state: TimerState) {
        guard let settings = settings else { return }
        self.timerState = state
        self.timeRemaining = settings.currentWorkType?.focusDuration ?? (25 * 60)
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
