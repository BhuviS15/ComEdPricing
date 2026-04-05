//
//  ContentView.swift
//  ComEdPricing
//
//  Created by You on 2/14/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var engine = RuleEngine()
    
    // Navigation State
    @State private var showingAddRule = false
    @State private var selectedRule: Rule?
    
    // UI Feedback State
    @State private var isRefreshing = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    // MARK: - Section 1: Price Dashboard
                    Section {
                        VStack(spacing: 12) {
                            Text("Current Price")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                            
                            if let price = engine.latestPrice {
                                Text("\(price, specifier: "%.2f")¢")
                                    .font(.system(size: 64, weight: .bold))
                                    .foregroundColor(price < 0 ? .green : .primary)
                            } else {
                                Text("--.--")
                                    .font(.system(size: 64, weight: .bold))
                                    .opacity(0.3)
                            }
                            
                            HStack {
                                StatusBadge(icon: "clock", text: engine.lastUpdatedDate?.formatted(date: .omitted, time: .shortened) ?? "Waiting...")
                                Spacer()
                                StatusBadge(icon: "bell.fill", text: engine.lastNotificationDate?.formatted(date: .omitted, time: .shortened) ?? "No alerts yet")
                            }
                            
                            // REFRESH BUTTON
                            Button(action: {
                                runManualRefresh()
                            }) {
                                HStack {
                                    if isRefreshing {
                                        ProgressView()
                                            .padding(.trailing, 5)
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                    }
                                    Text(isRefreshing ? "Updating..." : "Refresh Price")
                                        .fontWeight(.semibold)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .disabled(isRefreshing)
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // MARK: - Section 2: General Settings (NEW)
                    Section(header: Text("Monitor Mode")) {
                        Toggle(isOn: $engine.alwaysNotify) {
                            VStack(alignment: .leading) {
                                Text("Always Notify")
                                    .font(.headline)
                                Text("Get an alert every 5 minutes with the new price.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // MARK: - Section 3: Custom Alerts
                    Section(header: Text("Custom Alerts")) {
                        if engine.rules.isEmpty {
                            Text("No custom rules set.")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            // SAFE DELETION IMPLEMENTATION
                            ForEach($engine.rules) { $rule in
                                RuleRow(rule: $rule, onEdit: {
                                    selectedRule = rule
                                })
                            }
                            .onDelete(perform: deleteRule) // Helper function for safety
                        }
                    }
                    
                    // MARK: - Section 4: Testing
                    Section {
                        Button("Check for Alerts Now") {
                            runTestLogic()
                        }
                        .foregroundColor(.blue)
                    } footer: {
                        Text("Checks if the current price matches any alerts immediately.")
                    }
                }
                .refreshable {
                    runManualRefresh()
                }
                
                // TOAST MESSAGE OVERLAY
                if showToast {
                    VStack {
                        Spacer()
                        Text(toastMessage)
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(25)
                            .padding(.bottom, 30)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    .zIndex(100)
                }
            }
            .navigationTitle("ComEd Watcher")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: HistoryView(engine: engine)) {
                            Image(systemName: "list.bullet.rectangle")
                        }
                        Button(action: { showingAddRule = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddRule) {
                AddRuleView(engine: engine)
            }
            .sheet(item: $selectedRule) { rule in
                EditRuleView(engine: engine, ruleToEdit: rule)
            }
            .onAppear {
                engine.startMasterClock()
            }
        }
    }
    
    // MARK: - Actions
    
    func deleteRule(at offsets: IndexSet) {
        engine.rules.remove(atOffsets: offsets)
    }
    
    func runManualRefresh() {
        isRefreshing = true
        engine.refreshData { success in
            DispatchQueue.main.async {
                isRefreshing = false
                if success {
                    showToast(message: "Price Updated!")
                } else {
                    showToast(message: "Connection Failed")
                }
            }
        }
    }
    
    func runTestLogic() {
        guard let price = engine.latestPrice else {
            showToast(message: "Wait for price update...")
            return
        }
        
        if engine.runTestCycle() {
            showToast(message: "Notification Sent! 🔔")
        } else {
            showToast(message: "No Alerts Triggered (\(String(format: "%.2f", price))¢)")
        }
    }
    
    func showToast(message: String) {
        withAnimation {
            toastMessage = message
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

// Helper Views
struct StatusBadge: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(6)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

struct RuleRow: View {
    @Binding var rule: Rule
    var onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(rule.label)
                    .font(.headline)
                    .foregroundColor(rule.isEnabled ? .primary : .secondary)
                Text(rule.descriptionText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onEdit()
            }
            
            Spacer()
            
            Toggle("", isOn: $rule.isEnabled)
                .labelsHidden()
        }
        .opacity(rule.isEnabled ? 1.0 : 0.6)
    }
}
