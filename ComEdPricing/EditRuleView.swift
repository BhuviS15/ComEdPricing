//
//  EditRuleView.swift
//  ComEdPricing
//
//  Created by You on 2/14/26.
//

import SwiftUI

struct EditRuleView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var engine: RuleEngine
    
    // Temporary state for editing
    @State private var label: String
    @State private var condition: RuleCondition
    @State private var thresholdA: String
    @State private var thresholdB: String
    @State private var interval: Int
    @State private var ruleId: UUID
    
    let intervals = [1, 5, 10, 15, 30, 60]
    
    // Initialize with existing rule data
    init(engine: RuleEngine, ruleToEdit: Rule) {
        self.engine = engine
        _ruleId = State(initialValue: ruleToEdit.id)
        _label = State(initialValue: ruleToEdit.label)
        _condition = State(initialValue: ruleToEdit.condition)
        _thresholdA = State(initialValue: String(ruleToEdit.thresholdA))
        _thresholdB = State(initialValue: ruleToEdit.thresholdB != nil ? String(ruleToEdit.thresholdB!) : "")
        _interval = State(initialValue: ruleToEdit.intervalMinutes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rule Details")) {
                    TextField("Label", text: $label)
                    
                    Picker("Check Every", selection: $interval) {
                        ForEach(intervals, id: \.self) { min in
                            Text("\(min) minutes").tag(min)
                        }
                    }
                }
                
                Section(header: Text("Logic")) {
                    Picker("Condition", selection: $condition) {
                        ForEach(RuleCondition.allCases) { c in
                            Text(c.rawValue).tag(c)
                        }
                    }
                    
                    HStack {
                        Text(condition == .between || condition == .outside ? "Low / Min" : "Threshold")
                        Spacer()
                        TextField("0.0", text: $thresholdA)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if condition == .between || condition == .outside {
                        HStack {
                            Text("High / Max")
                            Spacer()
                            TextField("0.0", text: $thresholdB)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .navigationTitle("Edit Rule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    func saveChanges() {
        let t1 = Double(thresholdA) ?? 0.0
        let t2 = Double(thresholdB)
        
        let updatedRule = Rule(
            id: ruleId, // Keep original ID
            label: label,
            isEnabled: true, // Keep enabled if editing
            condition: condition,
            thresholdA: t1,
            thresholdB: t2,
            intervalMinutes: interval,
            lastFiredDate: nil
        )
        
        // This calls the function we just added back to RuleEngine
        engine.updateRule(updatedRule)
        dismiss()
    }
}
