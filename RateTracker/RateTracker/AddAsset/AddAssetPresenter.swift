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
    
    private let dataSourceSubject = CurrentValueSubject<[Contract.Cell], Never>([])
    private var cancelBag = [AnyCancellable]()
    
    var dataSource: AnyPublisher<[Contract.Cell], Never> {
        dataSourceSubject.eraseToAnyPublisher()
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
}

// MARK: - Private methods
private extension AddAssetPresenter {
    func bindSelf() {
        ratesFacade.getRemoteCurrencies()
            .compactMap { [weak self] remote in
                self?.map(remote)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.dataSourceSubject.send(result)
            }
            .store(in: &cancelBag)
    }
    
    func map(_ currencies: [TrackedCurrency]) -> [Contract.Cell] {
        currencies.map {
            .asset(.init(title: $0.code, subtitle: $0.name, isSelected: false))
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
