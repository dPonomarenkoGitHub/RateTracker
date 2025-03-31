//
//  RateFacade.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import Combine

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
    func getRates() -> AnyPublisher<RatesData, Never> {
        Deferred { [token] in
            Future() { promise in
                let router = GetLatestRatesRequest(token: token)
                
                HttpManager.request(router: router, completion: { (result: Result<RatesResponseDto, Error>) in
                    switch result {
                    case let .success(response):
                        promise(.success(RatesFacadeMapper.mapRemoteToDomain(response)))
                        return
                    case .failure:
                        promise(.success(.empty))
                        return
                    }
                })
            }
        }.eraseToAnyPublisher()
    }
    
    func getRemoteCurrencies() -> AnyPublisher<[TrackedCurrency], Never> {
        Deferred { [token] in
            Future() { promise in
                let router = GetCurrenciesRequest(token: token)
                
                HttpManager.request(router: router, completion: { (result: Result<[String: String], Error>) in
                    switch result {
                    case let .success(response):
                        promise(.success(RatesFacadeMapper.mapRemoteToDomain(response)))
                        return
                    case .failure:
                        promise(.success([]))
                        return
                    }
                })
            }
        }.eraseToAnyPublisher()
    }
    
    func getLocalCurrencies() -> AnyPublisher<[TrackedCurrency], Never> {
        realmManager.objects(TrackedCurrencyDb.self)
            .realmPublisher
            .map { $0.map(RatesFacadeMapper.mapDbToDomain) }
            .eraseToAnyPublisher()
    }
    
    func save(_ currencies: [TrackedCurrency]) {
        realmManager.add(RatesFacadeMapper.mapDomainToDb(currencies), update: true)
    }
    
    func remove(_ currency: TrackedCurrency) {
        realmManager.write { realm in
            guard let object = realm.object(ofType: TrackedCurrencyDb.self, forPrimaryKey: currency.code) else {
                return
            }
            realm.delete(object)
        }
    }
}
