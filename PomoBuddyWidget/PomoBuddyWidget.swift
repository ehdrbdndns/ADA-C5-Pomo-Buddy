import WidgetKit
import SwiftUI

struct PomoBuddyWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoBuddyActivityAttributes.self) { context in
            // MARK: - Lock Screen UI
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Image(context.state.characterImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12)
                    
                    Text(context.attributes.taskName)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                Text(statusText(for: context.state.timerState))
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                timerTextView(context: context)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            .cornerRadius(20)

        } dynamicIsland: { context in
            // MARK: - Dynamic Island UI
            DynamicIsland {
                // MARK: Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    timerTextView(context: context)
                        .font(.title)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.trailing)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Image(context.state.characterImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("\(context.attributes.taskName) - \(statusText(for: context.state.timerState))")
                        .font(.headline)
                        .padding(.top, 8)
                }
                
            } compactLeading: {
                // MARK: Compact Leading UI
                Image(context.state.characterImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(4)
                
            } compactTrailing: {
                // MARK: Compact Trailing UI
                timerTextView(context: context)
                    .frame(width: 50)
                
            } minimal: {
                // MARK: Minimal UI
                Image(context.state.characterImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(4)
            }
        }
    }
    
    private func statusText(for timerState: TimerState) -> String {
        switch timerState {
        case .focusing:
            return "Focusing"
        case .breaking:
            return "Break"
        case .paused:
            return "Paused"
        case .idle:
            return "Idle"
        }
    }
    
    @ViewBuilder
    private func timerTextView(context: ActivityViewContext<PomoBuddyActivityAttributes>) -> some View {
        if context.state.timerState == .paused {
            Text(context.state.timeRemainingString)
        } else {
            Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
        }
    }
}