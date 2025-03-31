//
//  DomainLayerDataProvider.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

enum DomainLayerDataProvider {
    public static var ratesFacade: RateFacadeProtocol = {
        RateFacade(
            realmManager: ServiceLayerDataProvider.realmManager,
            token: "8faa7beca76046af857394c068943644"
        )
    }()
}
