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
    
    private var cancelBag = [AnyCancellable]()

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
}

// MARK: - Private methods
private extension AssetListPresenter {
    func bindSelf() {
        ratesFacade.getLocalCurrencies()
            .sink { list in
                debugPrint("adsfsfd")
            }
            .store(in: &cancelBag)
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
