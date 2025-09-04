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
                
                Text(context.state.sessionState)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
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
                    Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
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
                    Text("\(context.attributes.taskName) - \(context.state.sessionState)")
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
                Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
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
}
