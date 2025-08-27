//
//  PomoBuddyWidgetLiveActivity.swift
//  PomoBuddyWidget
//
//  Created by Donggyun Yang on 8/21/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PomoBuddyWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PomoBuddyWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PomoBuddyWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PomoBuddyWidgetAttributes {
    fileprivate static var preview: PomoBuddyWidgetAttributes {
        PomoBuddyWidgetAttributes(name: "World")
    }
}

extension PomoBuddyWidgetAttributes.ContentState {
    fileprivate static var smiley: PomoBuddyWidgetAttributes.ContentState {
        PomoBuddyWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PomoBuddyWidgetAttributes.ContentState {
         PomoBuddyWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PomoBuddyWidgetAttributes.preview) {
   PomoBuddyWidgetLiveActivity()
} contentStates: {
    PomoBuddyWidgetAttributes.ContentState.smiley
    PomoBuddyWidgetAttributes.ContentState.starEyes
}
