//
//  AssetListCoordinatorPad.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import Foundation
import UIKit

class AssetListCoordinatorPad: AssetListCoordinator {
    var environment: CoordinatorEnvironment {
        .pad
    }
    
    weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func popupPresentationContext() -> UIViewController? {
        navigationController
    }
}
