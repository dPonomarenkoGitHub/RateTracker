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
    
    private lazy var doneButton = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(onDonePressed)
    )
    
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
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search asset"
        searchController.searchBar.isHidden = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
        
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isHidden = true
        
        tableView.register(cellType: AddAssetCell.self)
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.contentInset.top = 6
        tableView.delegate = self
        
        dataSource.defaultRowAnimation = .none
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
        
        presenter.isDoneHidden
            .sink { [doneButton] isHidden in
                doneButton.isHidden = isHidden
            }
            .store(in: &cancelBag)
    }
    
    @objc func onDonePressed() {
        presenter.apply()
        navigationController?.popViewController(animated: true)
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

extension AddAssetViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else { return }
        switch cell {
        case let .asset(model):
            presenter.select(model)
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


