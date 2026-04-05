//
//  RuleEngine.swift
//  ComEdPricing
//
//  Created by You on 2/14/26.
//

import Foundation
import UserNotifications
import Combine
import WidgetKit

class RuleEngine: ObservableObject {
    
    private let sharedDefaults = UserDefaults(suiteName: "group.com.bhuvi.ComEdPricing")
    
    // MARK: - State
    @Published var rules: [Rule] = [] {
        didSet { saveRules() }
    }
    
    // NEW: Always Notify Toggle
    @Published var alwaysNotify: Bool = false {
        didSet { saveSettings() }
    }
    
    @Published var latestPrice: Double? {
        didSet {
            if let price = latestPrice {
                // This pushes the price to the widget "bridge" automatically
                sharedDefaults?.set(price, forKey: "latestPrice")
                
                // This tells the widget "Hey, data changed! Reload now!"
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    @Published var priceHistory: [ComedPrice] = []
    @Published var lastUpdatedDate: Date?
    @Published var lastNotificationDate: Date?
    @Published var lastFiredRuleName: String?
    
    private var masterTimer: Timer?
    private let apiURL = URL(string: "https://hourlypricing.comed.com/api?type=5minutefeed")!
    
    init() {
        loadData()
    }
    
    // MARK: - Rule Management
    func updateRule(_ updatedRule: Rule) {
        if let index = rules.firstIndex(where: { $0.id == updatedRule.id }) {
            rules[index] = updatedRule
        }
    }
    
    // MARK: - Manual Refresh
    func refreshData(completion: @escaping (Bool) -> Void) {
        print("Engine: Manually refreshing price...")
        fetchPrice { [weak self] success in
            guard let self = self else { return }
            if success, let price = self.latestPrice {
                self.evaluateRules(with: price, force: true)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - Master Clock
    func startMasterClock() {
        masterTimer?.invalidate()
        requestNotificationPermissions()
        
        let now = Date()
        let calendar = Calendar.current
        let seconds = calendar.component(.second, from: now)
        let timeToNextMinute = 60.0 - Double(seconds)
        
        Timer.scheduledTimer(withTimeInterval: timeToNextMinute, repeats: false) { [weak self] _ in
            self?.startAlignedTimer()
        }
    }
    
    private func startAlignedTimer() {
        masterTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.performEvaluationCycle()
        }
        performEvaluationCycle()
    }
    
    // MARK: - Evaluation
    @discardableResult
    func performEvaluationCycle() -> Bool {
        fetchPrice { [weak self] success in
            guard let self = self, success, let price = self.latestPrice else { return }
            self.evaluateRules(with: price, force: false)
        }
        return false
    }
    
    func runTestCycle() -> Bool {
        guard let price = latestPrice else { return false }
        return evaluateRules(with: price, force: true)
    }
    
    @discardableResult
    private func evaluateRules(with price: Double, force: Bool) -> Bool {
        let now = Date()
        let calendar = Calendar.current
        let currentMinute = calendar.component(.minute, from: now)
        var didNotify = false
        
        // 1. CHECK ALWAYS NOTIFY (Runs every 5 mins when data updates)
        // We check 'force' so it doesn't spam you if you just tap "Refresh" manually,
        // unless it's a genuine 5-minute update interval.
        if alwaysNotify && (force || currentMinute % 5 == 0) {
             sendNotification(title: "Price Update", body: "Current: \(String(format: "%.2f", price))¢")
             didNotify = true
             
             DispatchQueue.main.async {
                 self.lastNotificationDate = now
                 self.lastFiredRuleName = "Always Notify"
             }
        }
        
        // 2. CHECK SPECIFIC RULES
        for (index, rule) in rules.enumerated() {
            guard rule.isEnabled else { continue }
            
            let isEligibleTime = force || (currentMinute % rule.intervalMinutes == 0)
            
            if isEligibleTime {
                if isConditionMet(rule: rule, price: price) {
                    // Only send if we haven't already sent a generic "Always Notify" to avoid double buzzing
                    // OR you can allow both. For now, let's send it specifically so you know WHY it buzzed.
                    sendNotification(title: "Alert: \(rule.label)", body: "\(rule.descriptionText). Price: \(String(format: "%.2f", price))¢")
                    
                    var updatedRule = rule
                    updatedRule.lastFiredDate = now
                    rules[index] = updatedRule
                    
                    didNotify = true
                    DispatchQueue.main.async {
                        self.lastNotificationDate = now
                        self.lastFiredRuleName = rule.label
                    }
                }
            }
        }
        return didNotify
    }
    
    private func isConditionMet(rule: Rule, price: Double) -> Bool {
        switch rule.condition {
        case .above: return price > rule.thresholdA
        case .below: return price < rule.thresholdA
        case .between: return price >= rule.thresholdA && price <= (rule.thresholdB ?? rule.thresholdA)
        case .outside: return price < rule.thresholdA || price > (rule.thresholdB ?? rule.thresholdA)
        }
    }
    
    // MARK: - Networking
    private func fetchPrice(completion: @escaping (Bool) -> Void) {
        URLSession.shared.dataTask(with: apiURL) { [weak self] data, _, error in
            guard let data = data else {
                completion(false)
                return
            }
            
            if let prices = try? JSONDecoder().decode([ComedPrice].self, from: data) {
                // Sort descending so index 0 is the newest
                let sorted = prices.sorted { $0.date > $1.date }
                
                DispatchQueue.main.async {
                    self?.priceHistory = sorted
                    if let first = sorted.first {
                        self?.latestPrice = first.priceValue
                        self?.sharedDefaults?.set(first.priceValue, forKey: "latestPrice")
                        self?.lastUpdatedDate = Date()
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - Persistence
    private func saveRules() {
        if let encoded = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(encoded, forKey: "savedRules")
        }
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(alwaysNotify, forKey: "alwaysNotify")
        sharedDefaults?.set(latestPrice, forKey: "latestPrice")
    }
    
    private func loadData() {
        // Load Rules
        if let data = UserDefaults.standard.data(forKey: "savedRules"),
           let decoded = try? JSONDecoder().decode([Rule].self, from: data) {
            rules = decoded
        }
        
        // Load Settings
        alwaysNotify = UserDefaults.standard.bool(forKey: "alwaysNotify")
    }
    
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
