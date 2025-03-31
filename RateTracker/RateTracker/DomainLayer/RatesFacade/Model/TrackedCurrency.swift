//
//  TrackedCurrency.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

struct TrackedCurrency {
    let code: String
    let name: String
    var rate: Double
    var updatedAt: Date?
    
    var rateString: String? {
        guard rate != 0 else { return nil }
        return String(format: "$%.3f", rate)
    }
    
    func update(rate: Double?, date: Date) -> TrackedCurrency {
        var copy = self
        copy.rate = rate ?? 0
        copy.updatedAt = date
        return copy
    }
}
