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
    private var cancelBag = [AnyCancellable]()

    init(coordinator: AssetListCoordinator) {
        self.coordinator = coordinator
        self.bindSelf()
    }
}

// MARK: - Private methods
private extension AssetListPresenter {
    func bindSelf() {
    }
}

// MARK: - DI
extension Assembly {
    func resolve(coordinator: AssetListCoordinator) -> AssetListPresenter {
        AssetListPresenter(coordinator: coordinator)
    }
}
