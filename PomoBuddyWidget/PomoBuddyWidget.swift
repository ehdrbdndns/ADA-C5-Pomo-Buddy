import WidgetKit
import SwiftUI

struct PomoBuddyWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoBuddyActivityAttributes.self) { context in
            // MARK: - Lock Screen UI
            VStack(alignment: .center, spacing: 8) {
                HStack(spacing: 4) {
                    Image(context.state.characterImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    
                    taskTextView(context: context)
                }
                
                timerTextView(context: context)
                    .font(.B3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 5)
                    .frame(width: .infinity)
                
//                intentButtonView(context: context)
//                    .padding(.horizontal, 24)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(20)

        } dynamicIsland: { context in
            // MARK: - Dynamic Island UI
            DynamicIsland {
                // MARK: Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    timerTextView(context: context)
                        .font(.custom("Melno", size: 42))
                        .fontWeight(.bold)
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
                // MARK: Compact Trailing UI
                VStack(alignment: .leading) {
                    timerTextView(context: context)
                        .font(.custom("Melno", size: 12))
                    
                    Text(statusText(for: context.state.timerState))
                        .font(.R1)
                        .foregroundStyle(statusColor(for: context.state.timerState))
                }
                .padding(.leading, 10)
                .frame(width: 40)
            } compactTrailing: {
                // MARK: Compact Leading UI
                Image(context.state.characterImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } minimal: {
                // MARK: Minimal UI
                Image(context.state.characterImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        }
    }
}

extension PomoBuddyWidget {
    private func statusText(for timerState: TimerState) -> String {
        switch timerState {
        case .focusing:
            return "Focus"
        case .breaking:
            return "Break"
        case .paused:
            return "Paused"
        case .idle:
            return "Idle"
        }
    }
    
    private func statusColor(for timerState: TimerState) -> Color {
        switch timerState {
        case .focusing:
            return Color.yellow1
        case .breaking:
            return Color.blue2
        case .idle, .paused:
            return Color.white
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
    
    @ViewBuilder
    private func taskTextView(context: ActivityViewContext<PomoBuddyActivityAttributes>) -> some View {
        switch context.state.timerState {
        case .focusing:
            Text("Focus")
                .font(.M5)
                .foregroundColor(Color.yellow1)
        case .idle, .paused:
            Text("Paused")
                .font(.M5)
                .foregroundColor(Color.white)
        case .breaking:
            Text("Break")
                .font(.M5)
                .foregroundColor(Color.blue2)
        }
    }
    
    @ViewBuilder
    private func intentButtonView(context: ActivityViewContext<PomoBuddyActivityAttributes>) -> some View {
        
        HStack(spacing: 12) {
            switch(context.state.timerState) {
            case .focusing:
                giveupButton
                pauseButton
            case .breaking:
                skipBreakButton
            case .paused, .idle:
                giveupButton
                resumeButton
            }
        }
    }
    
    var giveupButton: some View {
        Button {
            
        } label: {
            Text("Give Up")
                .font(.SB2)
        }
        .buttonStyle(CustomButtonStyle(
            backgroundColor: .black, foregroundColor: .grey20, borderColor: .grey10
        ))
    }
    
    var pauseButton: some View {
        Button {
            
        } label: {
            Text("Pause")
                .font(.SB2)
        }
        .buttonStyle(CustomButtonStyle(
            backgroundColor: .blackDim20, foregroundColor: .yellow1, borderColor: .yellow1
        ))
    }
    
    var resumeButton: some View {
        Button() {
            
        } label: {
            Text("Resume")
                .font(.SB2)
        }
        .buttonStyle(CustomButtonStyle(
            backgroundColor: .blackDim20, foregroundColor: .yellow1, borderColor: .yellow1
        ))
    }
    
    var skipBreakButton: some View {
        Button {
            
        } label: {
            Text("Skip Break")
                .font(.SB2)
        }
        .buttonStyle(CustomButtonStyle(
            backgroundColor: .blackDim20, foregroundColor: .blue2, borderColor: .blue2
        ))
    }
}
