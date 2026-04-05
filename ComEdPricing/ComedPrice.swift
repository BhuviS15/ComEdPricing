//
//  ComedPrice.swift
//  ComEdPricing
//
//  Created by You on 2/14/26.
//

import Foundation

struct ComedPrice: Decodable, Identifiable {
    let millisUTC: String
    let price: String
    
    // Conforming to Identifiable allows us to use it in a SwiftUI List
    var id: String { millisUTC }
    
    // Helper to convert the timestamp string to a real Date
    var date: Date {
        guard let ms = Double(millisUTC) else { return Date() }
        return Date(timeIntervalSince1970: ms / 1000)
    }
    
    // Helper to get the price as a Double
    var priceValue: Double {
        return Double(price) ?? 0.0
    }
}
