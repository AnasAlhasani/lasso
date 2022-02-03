//
// ==----------------------------------------------------------------------== //
//
//  TableViewDataSource.swift
//
//  Created by Anas Alhasani on 02/02/2022
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2022 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import UIKit

public final class TableViewDataSource<Item>: NSObject, UITableViewDataSource {
    public typealias CellProvider = (UITableView, IndexPath, Item) -> UITableViewCell
    public typealias CellConfigurator<Cell: UITableViewCell> = (Cell, IndexPath, Item) -> Void
    
    private let cellProvider: CellProvider
    private var items = [Item]()
    
    var tableView: UITableView?
    
    public init<Cell: UITableViewCell>(
        cellType: Cell.Type,
        cellConfigurator: @escaping CellConfigurator<Cell>
    ) {
        cellProvider = { tableView, indexPath, item in
            let cell: Cell = tableView.dequeueReusableCell(at: indexPath)
            cellConfigurator(cell, indexPath, item)
            return cell
        }
    }
    
    public init(cellProvider: @escaping CellProvider) {
        self.cellProvider = cellProvider
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellProvider(tableView, indexPath, items[indexPath.row])
    }
    
    @discardableResult
    public func appendItems(_ items: [Item]) -> Self {
        self.items = items
        return self
    }
    
    @discardableResult
    public func reloadData() -> Self {
        tableView?.reloadData()
        return self
    }
}

@available(iOS 13.0, *)
extension UITableViewDiffableDataSource {
    public func appendItems(
        _ items: [ItemIdentifierType],
        toSection section: SectionIdentifierType
    ) {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<SectionIdentifierType, ItemIdentifierType>()
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            self.apply(snapshot, animatingDifferences: true)
        }
    }
}

extension UITableView {
    public func dataSource<Cell: UITableViewCell, Item>(
        cellType: Cell.Type,
        cellConfigurator: @escaping TableViewDataSource<Item>.CellConfigurator<Cell>
    ) -> TableViewDataSource<Item> {
        if let dataSource = dataSource as? TableViewDataSource<Item> {
            dataSource.tableView = self
            return dataSource
        }
        else {
            let dataSource = TableViewDataSource<Item>(cellType: cellType, cellConfigurator: cellConfigurator)
            dataSource.tableView = self
            self.dataSource = dataSource
            return dataSource
        }
    }
    
    @available(iOS 13.0, *)
    public func diffableDataSource<Cell: UITableViewCell, Item: Hashable>(
        cellType: Cell.Type,
        cellConfigurator: @escaping TableViewDataSource<Item>.CellConfigurator<Cell>
    ) -> UITableViewDiffableDataSource<AnyHashable, Item> {
        if let dataSource = dataSource as? UITableViewDiffableDataSource<AnyHashable, Item> {
            return dataSource
        }
        else {
            return UITableViewDiffableDataSource<AnyHashable, Item>(tableView: self) { tableView, indexPath, item in
                let cell: Cell = tableView.dequeueReusableCell(at: indexPath)
                cellConfigurator(cell, indexPath, item)
                return cell
            }
        }
    }
}

extension UITableView {
    internal func dequeueReusableCell<Cell: UITableViewCell>(at indexPath: IndexPath) -> Cell {
        let cellIdentifier = String(describing: type(of: Cell.self))
        
        guard let cell = dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell of type: \(Cell.self) at indexPath: \(indexPath)")
        }
        
        return cell
    }
}
