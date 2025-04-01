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
    private let lastUpdatedSubject = CurrentValueSubject<Date?, Never>(nil)
    private var cancelBag = [AnyCancellable]()
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM HH:mm:ss"
        return formatter
    }()
    
    
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
        
        
        Publishers.CombineLatest(localCurrenciesSubject, lastUpdatedSubject)
            .compactMap { [weak self] remote, lastUpdate in
                self?.map(remote, updated: lastUpdate)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.dataSourceSubject.send(result)
            }
            .store(in: &cancelBag)
        
        let ratesPublisher = Timer.publish(every: 5, tolerance: 0.5, on: .main, in: .common)
            .autoconnect()
            .map { [ratesFacade] _ in
                ratesFacade.getRates()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
                
        Publishers.CombineLatest(ratesPublisher, localCurrenciesSubject)
            .sink { [weak self] data , local in
                guard !local.isEmpty else { return }
                let updated = local.map {
                    $0.update(rate: data.rates[$0.code], date: data.updatedAt)
                }
                self?.lastUpdatedSubject.send(Date())
                self?.ratesFacade.save(updated)
            }
            .store(in: &cancelBag)
    }
    
    func map(_ currencies: [TrackedCurrency], updated: Date?) -> [Contract.Cell] {
        var cells = [Contract.Cell]()
        
        if let updated, !currencies.isEmpty {
            let status = "Last updated: \(formatter.string(from: updated))"
            cells.append(.status(status))
        }
        
        cells.append(contentsOf: currencies.map {
            .asset(.init(
                title: $0.code,
                subtitle: $0.name,
                rate: $0.rateString
            ))
        })
        
        if cells.isEmpty {
            cells.append(.empty)
        }
        
        return cells
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
