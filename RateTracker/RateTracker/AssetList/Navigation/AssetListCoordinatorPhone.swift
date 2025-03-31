//
//  AssetListCoordinatorPhone.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import UIKit

class AssetListCoordinatorPhone: AssetListCoordinator {
    var environment: CoordinatorEnvironment {
        .phone
    }

    weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func popupPresentationContext() -> UIViewController? {
        navigationController
    }
    
    func showAddAsset() {
        let controller: AddAssetViewController = Assembly().resolve(
            coordinator: AddAssetCoordinatorPhone(navigationController: navigationController)
        )
        navigationController.pushViewController(controller, animated: true)
    }
}
