//
//  RateFacade.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation

final class RateFacade {
    private let realmManager: RealmManagerProtocol
    private let token: String
    
    init(
        realmManager: RealmManagerProtocol,
        token: String
    ) {
        self.realmManager = realmManager
        self.token = token
    }
}

extension RateFacade: RateFacadeProtocol {
    func get() {
        let router = GetLatestRatesRequest(token: token)
        
        HttpManager.request(router: router, completion: { (result: Result<RatesResponseDto, Error>) in
            switch result {
            case let .success(response):
                print("Success: \(response)")
            case let .failure(error):
                print("Error: \(error)")
            }
        })
    }
}
