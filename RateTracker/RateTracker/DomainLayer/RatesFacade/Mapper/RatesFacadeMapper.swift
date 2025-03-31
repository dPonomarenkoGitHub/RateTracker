//
//  RatesFacadeMapper.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

enum RatesFacadeMapper {
    static func mapDbToDomain(_ from: [TrackedCurrencyDb]) -> [TrackedCurrency] {
        from.map { mapDbToDomain($0) }
    }
    
    static func mapDbToDomain(_ from: TrackedCurrencyDb) -> TrackedCurrency {
        .init(
            code: from.code,
            name: from.name,
            rate: from.rate,
            updatedAt: from.updatedAt.map { Date(timeIntervalSince1970: TimeInterval($0)) }
        )
    }
    
    static func mapRemoteToDomain(_ from: [String: String]) -> [TrackedCurrency] {
        from.map { item in
            TrackedCurrency(code: item.key, name: item.value, rate: 0, updatedAt: nil)
        }
    }
}
