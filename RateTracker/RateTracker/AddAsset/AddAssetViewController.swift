//
//  AddAssetViewController.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import UIKit
import Combine
import Reusable

final class AddAssetViewController: UIViewController {
    typealias Contract = AddAssetContract
    
    var presenter: AddAssetPresenter!
    
    private lazy var dataSource = makeDataSource()
    private var cancelBag = [AnyCancellable]()
    
    @IBOutlet private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindPresenter()
    }
}

// MARK: - Private methods
private extension AddAssetViewController {
    func setupUI() {
        title = "Add Asset"
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = presenter
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search asset"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        tableView.register(cellType: AddAssetCell.self)
        tableView.contentInset.top = 6
    }
    
    func bindPresenter() {
        presenter.dataSource
            .sink { [weak self] cells in
                var snapshot = NSDiffableDataSourceSnapshot<Int, Contract.Cell>()
                snapshot.appendSections([0])
                snapshot.appendItems(cells)
                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancelBag)
    }
}

private extension AddAssetViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Int, Contract.Cell> {
        .init(tableView: tableView) { tableView, indexPath, cell in
            switch cell {
            case let .asset(model):
                return tableView.dequeueReusableCell(for: indexPath, cellType: AddAssetCell.self).then {
                    $0.setup(with: model)
                }
            }
        }
    }
}



// MARK: - DI
extension Assembly {
    func resolve(coordinator: AddAssetCoordinator) -> AddAssetViewController {
        AddAssetViewController().then {
            $0.presenter = resolve(coordinator: coordinator)   
        }
    }
}


