//
//  TrackedCurrencyDb.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import RealmSwift

public final class TrackedCurrencyDb: Object {
    @Persisted(primaryKey: true) var code: String
    @Persisted public var name: String
    @Persisted public var rate: Double
    @Persisted public var updatedAt: Double?
    
    public convenience init(
        code: String,
        name: String,
        rate: Double,
        updatedAt: Double?
    ) {
        self.init()
        self.code = code
        self.name = name
        self.rate = rate
        self.updatedAt = updatedAt
    }
}
