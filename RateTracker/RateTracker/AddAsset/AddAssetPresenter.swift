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
        let filtered: [TrackedCurrency] = dataSourceSubject
            .value.map {
                switch $0 {
                case let .asset(model):
                    return model
                }
            }
            .filter {
                selectedCodesSubject.value.contains($0.title)
            }
            .map {
                .init(code: $0.title, name: $0.subtitle, rate: 0, updatedAt: nil)
            }
        
        ratesFacade.save(filtered)
    }
}

// MARK: - Private methods
private extension AddAssetPresenter {
    func bindSelf() {
        Publishers.CombineLatest(
            ratesFacade.getRemoteCurrencies(),
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
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        let searchText = (searchController.searchBar.text ?? "")
        //self.currentSearchText = searchText
        //search()
        debugPrint(searchText)
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
