//
//  RatesData.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

struct RatesData {
    let updatedAt: Date
    let base: String
    let rates: [String: Double]
    
    static var empty: RatesData {
        .init(updatedAt: Date(), base: "", rates: [:])
    }
}
