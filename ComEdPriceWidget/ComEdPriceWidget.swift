//
//  ComEdPriceWidget.swift
//  ComEdPriceWidget
//
//  Created by Bhuvi Singh on 3/22/26.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    // FIX 1: Added price: 0.0
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), price: 0.0)
    }

    // FIX 2: Added price: 2.50 (for the gallery preview)
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, price: 2.50)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let shared = UserDefaults(suiteName: "group.com.bhuvi.ComEdPricing")
        let currentPrice = shared?.double(forKey: "latestPrice") ?? 0.0
        
        let entry = SimpleEntry(date: .now, configuration: configuration, price: currentPrice)

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: .now)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        return timeline
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let price: Double
}

struct ComEdPriceWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            // THIS IS YOUR SMALL ICON
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 10))
                    Text("\(Int(entry.price))")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            
        case .accessoryRectangular:
            // WIDE LOCK SCREEN
            VStack(alignment: .leading, spacing: 0) {
                Text("COMED").font(.caption2).fontWeight(.black)
                Text("\(entry.price, specifier: "%.2f")¢")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
            }

        case .systemSmall:
            // HOME SCREEN
            VStack {
                Text("Current").font(.caption).foregroundColor(.secondary)
                Text("\(entry.price, specifier: "%.2f")¢")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(entry.price < 0 ? .green : .primary)
            }
            .containerBackground(.fill.tertiary, for: .widget)

        default:
            Text("\(entry.price, specifier: "%.2f")¢")
        }
    }
}

struct ComEdPriceWidget: Widget {
    let kind: String = "ComEdPriceWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ComEdPriceWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        // ADD THIS: Tells iOS this widget can go on the Lock Screen
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

// You can leave the ConfigurationAppIntent extensions as they are
extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

// FIX 3: Added price: 1.85 to the preview entries
#Preview(as: .systemSmall) {
    ComEdPriceWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, price: 1.85)
    SimpleEntry(date: .now, configuration: .starEyes, price: 2.10)
}
