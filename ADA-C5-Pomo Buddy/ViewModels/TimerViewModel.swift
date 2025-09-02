
import Foundation
import SwiftUI
import SwiftData

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
    
    func start() {
        guard timerState == .idle || timerState == .breaking else { return }
        timeRemaining = settings?.currentWorkType?.focusDuration ?? (25 * 60)
        timerState = .focusing
        
        liveActivityManager.startLiveActivity(taskName: "코딩하기", characterImageName: "quokka_char_image", timeString: timeRemaining.formattedTimeString, timeRemaining: self.timeRemaining)
        
        runTimer()
    }
    
    func pause() {
        guard timerState == .focusing || timerState == .breaking else { return }
        prePauseState = timerState
        timer?.invalidate()
        timerState = .paused
    }
    
    func resume() {
        guard timerState == .paused else { return }
        timerState = prePauseState
        runTimer()
    }
    
    func giveUp() {
        timer?.invalidate()
        liveActivityManager.endLiveActivity()
        resetTimer(to: .idle)
    }
    
    func skipBreak() {
        timer?.invalidate()
        liveActivityManager.endLiveActivity()
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
    
    // MARK: - Private Methods
    
    private func runTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            handleTimerCompletion()
            return
        }
        timeRemaining -= 1
        
        liveActivityManager.updateLiveActivity(
            timeString: timeRemaining.formattedTimeString
            , sessionState: self.timerState == .focusing ? "Focus" : "Break"
            , timeRemaining: self.timeRemaining
        )
    }
    
    private func handleTimerCompletion() {
        timer?.invalidate()
        switch timerState {
        case .focusing:
            transitionToBreak()
        case .breaking:
            liveActivityManager.endLiveActivity()
            transitionToNextSession()
        default:
            resetTimer(to: .idle)
        }
    }
    
    private func transitionToBreak() {
        guard let settings = settings else { return }
        
        let log = FocusLog(date: .now, focusDuration: settings.currentWorkType?.focusDuration ?? (25 * 60))
        modelContext.insert(log)
        fetchFocusLogs() // Refetch to update the count and array
        
        timerState = .breaking
        timeRemaining = settings.currentWorkType?.breakDuration ?? (5 * 60)
        
        liveActivityManager.updateLiveActivity(timeString: timeRemaining.formattedTimeString, sessionState: "Break", timeRemaining: self.timeRemaining)
        
        runTimer()
    }
    
    private func transitionToNextSession() {
        guard let settings = settings else { return }
        if settings.isAutoTimerEnabled {
            timerState = .focusing
            timeRemaining = settings.currentWorkType?.focusDuration ?? (25 * 60)
            
            liveActivityManager.updateLiveActivity(timeString: timeRemaining.formattedTimeString, sessionState: "Focus", timeRemaining: self.timeRemaining)
            
            runTimer()
        } else {
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
