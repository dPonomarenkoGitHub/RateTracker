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
    let rate: Double
    let updatedAt: Date?
}
