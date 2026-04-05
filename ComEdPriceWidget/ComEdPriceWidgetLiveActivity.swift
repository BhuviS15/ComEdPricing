//
//  ComEdPriceWidgetLiveActivity.swift
//  ComEdPriceWidget
//
//  Created by Bhuvi Singh on 3/22/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ComEdPriceWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ComEdPriceWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ComEdPriceWidgetAttributes.self) { context in
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

extension ComEdPriceWidgetAttributes {
    fileprivate static var preview: ComEdPriceWidgetAttributes {
        ComEdPriceWidgetAttributes(name: "World")
    }
}

extension ComEdPriceWidgetAttributes.ContentState {
    fileprivate static var smiley: ComEdPriceWidgetAttributes.ContentState {
        ComEdPriceWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ComEdPriceWidgetAttributes.ContentState {
         ComEdPriceWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ComEdPriceWidgetAttributes.preview) {
   ComEdPriceWidgetLiveActivity()
} contentStates: {
    ComEdPriceWidgetAttributes.ContentState.smiley
    ComEdPriceWidgetAttributes.ContentState.starEyes
}
