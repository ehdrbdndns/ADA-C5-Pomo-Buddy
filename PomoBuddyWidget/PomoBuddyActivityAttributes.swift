import Foundation
import ActivityKit

struct PomoBuddyActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var sessionState: String
        var timeRemaining: String // 초기 표시용 문자열
        var endTime: Date         // 위젯이 스스로 카운트다운할 목표 시간
    }
    
    var taskName: String
    var characterImageName: String
}