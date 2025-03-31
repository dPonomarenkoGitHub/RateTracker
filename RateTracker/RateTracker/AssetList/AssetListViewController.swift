//
//  AssetListViewController.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import UIKit
import Combine

final class AssetListViewController: UIViewController {
    typealias Contract = AssetListContract
    
    var presenter: AssetListPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindPresenter()
    }
}

// MARK: - Private methods
private extension AssetListViewController {
    func setupUI() {
        title = "Exchange Rates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(onAddPressed)
        )
    }
    
    func bindPresenter() {
    }
    
    @objc func onAddPressed() {
        presenter.showAddAsset()
    }
}

// MARK: - DI
extension Assembly {
    func resolve(coordinator: AssetListCoordinator) -> AssetListViewController {
        AssetListViewController().then {
            $0.presenter = resolve(coordinator: coordinator)   
        }
    }
}


