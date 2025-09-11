import Foundation

struct TimerStateEngine {
    
    struct TransitionResult {
        let nextState: TimerState
        let duration: TimeInterval
        let characterImageName: String
        let shouldLogFocusSession: Bool
    }
    
    static func calculate(from currentState: TimerState, workType: WorkType, isAutoTimerEnabled: Bool) -> TransitionResult? {
        
        let nextState: TimerState
        
        switch currentState {
        case .focusing:
            nextState = .breaking
        case .breaking:
            if isAutoTimerEnabled {
                nextState = .focusing
            } else {
                return nil // Indicates a transition to idle
            }
        default:
            return nil // Not a state we can transition from
        }
        
        let duration: TimeInterval
        let characterImageName: String
        let shouldLogFocusSession: Bool

        switch nextState {
        case .breaking:
            duration = workType.breakDuration
            characterImageName = "hamster-break"
            shouldLogFocusSession = true
            
        case .focusing:
            duration = workType.focusDuration
            characterImageName = "hamster-focus"
            shouldLogFocusSession = false
            
        default:
            return nil
        }

        return TransitionResult(
            nextState: nextState,
            duration: duration,
            characterImageName: characterImageName,
            shouldLogFocusSession: shouldLogFocusSession
        )
    }
}
