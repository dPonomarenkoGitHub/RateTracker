//
//  AssetListViewController.swift
//  RateTracker
//
//  Created by Dmitry Ponomarenko on 31.03.2025.
//

import UIKit
import Combine
import Reusable

final class AssetListViewController: UIViewController {
    typealias Contract = AssetListContract
    
    var presenter: AssetListPresenter!
    
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
private extension AssetListViewController {
    func setupUI() {
        title = "Exchange Rates"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(onAddPressed)
        )
        
        tableView.register(cellType: AssetCell.self)
        tableView.register(cellType: UpdateStatusCell.self)
        tableView.register(cellType: AssetEmptyCell.self)
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
    }
    
    @objc func onAddPressed() {
        presenter.showAddAsset()
    }
}

private extension AssetListViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Int, Contract.Cell> {
        .init(tableView: tableView) { tableView, indexPath, cell in
            switch cell {
            case let .asset(model):
                return tableView.dequeueReusableCell(for: indexPath, cellType: AssetCell.self).then {
                    $0.setup(with: model)
                }
            case let .status(text):
                return tableView.dequeueReusableCell(for: indexPath, cellType: UpdateStatusCell.self).then {
                    $0.setup(with: text)
                }
            case .empty:
                return tableView.dequeueReusableCell(for: indexPath, cellType: AssetEmptyCell.self)
            }
        }
    }
}

extension AssetListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        switch cell {
        case let .asset(model):
            let deleteAction = UIContextualAction(
               style: .destructive,
               title: "Delete") { [weak self] _, _, complete in
                   self?.presenter.remove(model)
               }
            deleteAction.backgroundColor = .red

            return UISwipeActionsConfiguration(actions: [deleteAction])
        default:
            return nil
        }
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


