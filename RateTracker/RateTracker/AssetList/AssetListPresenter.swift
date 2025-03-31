//
//  AssetListPresenter.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import Combine

final class AssetListPresenter {
    typealias Contract = AssetListContract
    
    private let coordinator: AssetListCoordinator
    private let ratesFacade: RateFacadeProtocol
    
    private let dataSourceSubject = CurrentValueSubject<[Contract.Cell], Never>([])
    private let localCurrenciesSubject = CurrentValueSubject<[TrackedCurrency], Never>([])
    private var cancelBag = [AnyCancellable]()
    
    var dataSource: AnyPublisher<[Contract.Cell], Never> {
        dataSourceSubject.eraseToAnyPublisher()
    }

    init(
        coordinator: AssetListCoordinator,
        ratesFacade: RateFacadeProtocol
    ) {
        self.coordinator = coordinator
        self.ratesFacade = ratesFacade
        self.bindSelf()
    }
    
    func showAddAsset() {
        coordinator.showAddAsset()
    }
    
    func remove(_ model: Contract.Model) {
        guard let removed: TrackedCurrency = localCurrenciesSubject.value.first(where: { $0.code == model.title }) else {
            return
        }
        ratesFacade.remove(removed)
    }
}

// MARK: - Private methods
private extension AssetListPresenter {
    func bindSelf() {
        ratesFacade.getLocalCurrencies()
            .sink { [weak self] in
                self?.localCurrenciesSubject.send($0)
            }
            .store(in: &cancelBag)
        
        
        localCurrenciesSubject
            .compactMap { [weak self] remote in
                self?.map(remote)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.dataSourceSubject.send(result)
            }
            .store(in: &cancelBag)
        
        Publishers.CombineLatest(ratesFacade.getRates(), localCurrenciesSubject)
            .sink { [weak self] data , local in
                let updated = local.map {
                    $0.update(rate: data.rates[$0.code], date: data.updatedAt)
                }
                self?.ratesFacade.save(updated)
            }
            .store(in: &cancelBag)
    }
    
    func map(_ currencies: [TrackedCurrency]) -> [Contract.Cell] {
        currencies.map {
            .asset(.init(
                title: $0.code,
                subtitle: $0.name,
                rate: $0.rateString
            ))
        }
    }
}

// MARK: - DI
extension Assembly {
    func resolve(coordinator: AssetListCoordinator) -> AssetListPresenter {
        AssetListPresenter(
            coordinator: coordinator,
            ratesFacade: DomainLayerDataProvider.ratesFacade
        )
    }
}
