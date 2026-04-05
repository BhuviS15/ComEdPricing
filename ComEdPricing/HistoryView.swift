//
//  HistoryView.swift
//  ComEdPricing
//
//  Created by Bhuvi Singh on 2/15/26.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var engine: RuleEngine
    
    // Computed property to filter logs for the last 12 hours
    var filteredHistory: [ComedPrice] {
        let twelveHoursAgo = Date().addingTimeInterval(-12 * 3600)
        return engine.priceHistory.filter { $0.date > twelveHoursAgo }
    }
    
    var body: some View {
        List {
            Section(header: Text("Last 12 Hours")) {
                if filteredHistory.isEmpty {
                    Text("No data available yet.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filteredHistory) { log in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(log.date.formatted(date: .omitted, time: .shortened))
                                    .font(.headline)
                                Text(log.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("\(log.priceValue, specifier: "%.2f")¢")
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(colorForPrice(log.priceValue))
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Price Logs")
    }
    
    func colorForPrice(_ price: Double) -> Color {
        if price < 0 { return .green }
        if price > 5.0 { return .red } // Arbitrary "high" threshold for visual aid
        return .primary
    }
}
