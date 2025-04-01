//
//  TrackedCurrency.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import UIKit

struct TrackedCurrency {
    let code: String
    let name: String
    var rate: Double
    var updatedAt: Date?
    
    var rateString: NSAttributedString? {
        guard rate != 0 else { return nil }
        let string = NSMutableAttributedString(string: String(format: "%.3f", rate), attributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
            .foregroundColor: UIColor.label
        ])
        
        let relative = NSAttributedString(string: " (≈$1)", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ])
        string.append(relative)
        
        return string
    }
    
    func update(rate: Double?, date: Date) -> TrackedCurrency {
        var copy = self
        copy.rate = rate ?? 0
        copy.updatedAt = date
        return copy
    }
}
