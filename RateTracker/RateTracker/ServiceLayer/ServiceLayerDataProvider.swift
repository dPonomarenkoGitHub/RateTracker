//
//  ServiceLayerDataProvider.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

enum ServiceLayerDataProvider {
    public static var realmManager: RealmManagerProtocol = {
        RealmManager.shared
    }()
}
