//
//  AddRuleView.swift
//  ComEdPricing
//
//  Created by You on 2/14/26.
//

import SwiftUI

struct AddRuleView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var engine: RuleEngine
    
    @State private var label = ""
    @State private var condition: RuleCondition = .above
    @State private var thresholdA = ""
    @State private var thresholdB = ""
    @State private var interval = 5
    
    let intervals = [1, 5, 10, 15, 30, 60]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alert Name")) {
                    TextField("e.g. Price Spike", text: $label)
                }
                
                Section(header: Text("Trigger Alert When...")) {
                    Picker("Condition", selection: $condition) {
                        ForEach(RuleCondition.allCases) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    HStack {
                        Text(condition == .between || condition == .outside ? "Low Price" : "Price Limit")
                        Spacer()
                        TextField("0.0", text: $thresholdA)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if condition == .between || condition == .outside {
                        HStack {
                            Text("High Price")
                            Spacer()
                            TextField("0.0", text: $thresholdB)
                            .keyboardType(.numbersAndPunctuation)
                            .multilineTextAlignment(.trailing)
                        }
                    }
                }
                
                Section(header: Text("How often to check?")) {
                    Picker("Check Every", selection: $interval) {
                        ForEach(intervals, id: \.self) { min in
                            Text("\(min) minutes").tag(min)
                        }
                    }
                }
            }
            .navigationTitle("New Alert")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRule()
                    }
                    .disabled(label.isEmpty || thresholdA.isEmpty)
                }
            }
        }
    }
    
    func saveRule() {
        let t1 = Double(thresholdA) ?? 0.0
        let t2 = Double(thresholdB)
        
        let newRule = Rule(
            label: label,
            condition: condition,
            thresholdA: t1,
            thresholdB: t2,
            intervalMinutes: interval
        )
        
        // Add to TOP of stack (High priority by default)
        engine.rules.insert(newRule, at: 0)
        dismiss()
    }
}
