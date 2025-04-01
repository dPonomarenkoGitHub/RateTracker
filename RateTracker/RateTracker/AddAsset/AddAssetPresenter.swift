//
//  AddAssetPresenter.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import Combine
import UIKit

final class AddAssetPresenter: NSObject {
    typealias Contract = AddAssetContract
    
    private let coordinator: AddAssetCoordinator
    private let ratesFacade: RateFacadeProtocol
    
    private let selectedCodesSubject = CurrentValueSubject<Set<String>, Never>(Set([]))
    private let dataSourceSubject = CurrentValueSubject<[Contract.Cell], Never>([])
    private let remoteCurrenciesSubject = CurrentValueSubject<[TrackedCurrency], Never>([])
    private let searchQuerySubject = CurrentValueSubject<String, Never>("")
    private var cancelBag = [AnyCancellable]()
    
    var dataSource: AnyPublisher<[Contract.Cell], Never> {
        dataSourceSubject.eraseToAnyPublisher()
    }
    
    var isDoneHidden: AnyPublisher<Bool, Never> {
        selectedCodesSubject
            .map { $0.count == 0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    init(
        coordinator: AddAssetCoordinator,
        ratesFacade: RateFacadeProtocol
    ) {
        self.coordinator = coordinator
        self.ratesFacade = ratesFacade
        super.init()
        self.bindSelf()
    }
    
    func select(_ model: Contract.AssetModel) {
        var existing = selectedCodesSubject.value
        if existing.contains(model.title) {
            existing.remove(model.title)
        } else {
            existing.insert(model.title)
        }
        selectedCodesSubject.send(existing)
    }
    
    func apply() {
        let filtered: [TrackedCurrency] = remoteCurrenciesSubject.value.filter {
            selectedCodesSubject.value.contains($0.code)
        }
        ratesFacade.save(filtered)
    }
}

// MARK: - Private methods
private extension AddAssetPresenter {
    func bindSelf() {
        let queryPublisher = searchQuerySubject
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
        
        ratesFacade.getRemoteCurrencies()
            .sink { [weak self] currencies in
                guard let self else { return }
                let localCodes = self.ratesFacade.getLocalCurrenciesCodes()
                let filtered = currencies.filter { !localCodes.contains($0.code) }
                self.remoteCurrenciesSubject.send(filtered)
            }
            .store(in: &cancelBag)
        
        let filteredCurrenciesPublisher = Publishers.CombineLatest(
            queryPublisher,
            remoteCurrenciesSubject
        )
            .map { query, currencies in
                guard !query.isEmpty else { return currencies }
                return currencies.filter({
                    $0.code.lowercased().contains(query.lowercased()) ||
                    $0.name.lowercased().contains(query.lowercased()) })
            }
            .eraseToAnyPublisher()
        
        Publishers.CombineLatest(
            filteredCurrenciesPublisher,
            selectedCodesSubject
        )
            .compactMap { [weak self] remote, selectedCodes in
                self?.map(remote, selected: selectedCodes)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.dataSourceSubject.send(result)
            }
            .store(in: &cancelBag)
    }
    
    func map(_ currencies: [TrackedCurrency], selected: Set<String>) -> [Contract.Cell] {
        currencies.map {
            .asset(.init(
                title: $0.code,
                subtitle: $0.name,
                isSelected: selected.contains($0.code)
            ))
        }
    }
}

extension AddAssetPresenter: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        searchQuerySubject.send(searchText)
    }
}

// MARK: - DI
extension Assembly {
    func resolve(coordinator: AddAssetCoordinator) -> AddAssetPresenter {
        AddAssetPresenter(
            coordinator: coordinator,
            ratesFacade: DomainLayerDataProvider.ratesFacade
        )
    }
}
