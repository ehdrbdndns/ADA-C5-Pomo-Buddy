import Foundation

// Defines the actions that are performed after a timer session completes or is reset.
// Concrete implementations will be created for the foreground and background contexts,
// as some actions (like updating the UI) should only happen in the foreground.
protocol TransitionPerformer {
    
    // Transitions the state based on a calculation result.
    func performTransition(using result: TimerStateEngine.TransitionResult, workType: WorkType)
    
    // Resets the state to idle.
    func resetToIdle()
}
