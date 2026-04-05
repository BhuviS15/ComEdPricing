//
//  RuleCondition.swift
//  ComEdPricing
//
//  Created by Bhuvi Singh on 2/14/26.
//

import Foundation

enum RuleCondition: String, Codable, CaseIterable, Identifiable {
    case above = "Price is High (>)"
    case below = "Price is Low (<)"
    case between = "Inside Range"
    case outside = "Outside Range (Extreme)"
    
    var id: String { rawValue }
}

struct Rule: Identifiable, Codable, Equatable {
    var id = UUID()
    var label: String
    var isEnabled: Bool = true
    
    // Logic Settings
    var condition: RuleCondition
    var thresholdA: Double // Used for Above/Below, or Min for Range
    var thresholdB: Double? // Used for Range Max
    
    // Scheduling
    var intervalMinutes: Int // e.g., 5, 10, 30, 60
    
    // Telemetry
    var lastFiredDate: Date?
    
    // Helper for UI
    var descriptionText: String {
        switch condition {
        case .above: return "Above \(String(format: "%.2f", thresholdA))¢"
        case .below: return "Below \(String(format: "%.2f", thresholdA))¢"
        case .between: return "\(String(format: "%.2f", thresholdA))¢ - \(String(format: "%.2f", thresholdB ?? 0))¢"
        case .outside: return "Outside \(String(format: "%.2f", thresholdA))¢ - \(String(format: "%.2f", thresholdB ?? 0))¢"
        }
    }
}
