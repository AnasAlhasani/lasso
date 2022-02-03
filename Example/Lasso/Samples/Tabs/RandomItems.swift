//
// ==----------------------------------------------------------------------== //
//
//  RandomItems.swift
//
//  Created by Steven Grosmark on 5/21/19.
//
//
//  This source file is part of the Lasso open source project
//
//     https://github.com/ww-tech/lasso
//
//  Copyright © 2019-2020 WW International, Inc.
//
// ==----------------------------------------------------------------------== //
//

import UIKit
import Lasso

/// Displays a searchable table view of items.
/// Selecting an item shows details for the item
///
/// This flow emits No output.
/// This flow requires that it is placed in a  navigation controller.
class RandomItemsFlow: Flow<NoOutputNavigationFlow> {
    
    /// Creates the initial view controller for the RandomItemsFlow -
    /// the searchable table view of items.
    override func createInitialController() -> UIViewController {
        return RandomItems
            .createScreen()
            .observeOutput(handleOutput)
            .controller
    }
    
    /// Handles the Output from the RandomItems screen - the table view
    private func handleOutput(_ output: RandomItems.Output) {
        switch output {
            
        case .didSelectItem(let item):
            let state = TextScreenModule.State(title: item.name,
                                               description: item.description)
            TextScreenModule
                .createScreen(with: state)
                .place(with: nextPushedInFlow)
        }
    }
}

enum RandomItems: ScreenModule {
    
    static var defaultInitialState: State { return State() }
    
    static func createScreen(with store: RandomItemsStore) -> Screen {
        let controller = RandomItemsViewController(store: store.asViewStore())
        return Screen(store, controller)
    }

    enum Action: Equatable {
        case didSelectRow(IndexPath)
        case didUpdateSearchQuery(String?)
    }
    
    enum Output: Equatable {
        case didSelectItem(Item)
    }
    
    struct State: Equatable {
        let items: [Item]
        var query: String?
        var foundItems: [Item]? {
            didSet { allItems = foundItems ?? items }
        }
        
        var allItems = [Item]()
    }
    
    enum Section { case main }
    
    struct Item: Equatable, Hashable {
        let name: String
        let description: String
    }
    
}

class RandomItemsStore: LassoStore<RandomItems> {
    
    override func handleAction(_ action: RandomItems.Action) {
        switch action {
            
        case .didSelectRow(let indexPath):
            let item = state.allItems[indexPath.row]
            dispatchOutput(.didSelectItem(item))
            
        case .didUpdateSearchQuery(let query):
            if let query = query, !query.isEmpty {
                update { state in
                    state.query = query
                    state.foundItems = state.items.filter { $0.name.range(of: query, options: .caseInsensitive) != nil }
                }
            }
            else {
                update { state in
                    state.query = nil
                    state.foundItems = nil
                }
            }
        }
    }
}

extension RandomItems.State {
    init() {
        var items = [RandomItems.Item]()
        for _ in 0..<30 {
            let item = RandomItems.Item(name: String.randomWord().capitalized,
                                        description: .loremIpsum(sentences: Int.random(in: 1...4)))
            items.append(item)
        }
        self.items = items
    }
}

class RandomItemsViewController: UIViewController, LassoView {
    
    let store: RandomItems.ViewStore
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    init(store: RandomItems.ViewStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        
        tableView.register(type: UITableViewCell.self)

        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        // Allows search controller to get pushed along with everything else, and maintain its state:
        definesPresentationContext = true
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(tableView)
        
        tableView.layout.fill(.safeArea)
        
        setUpBindings()
    }
    
    private func setUpBindings() {
        if #available(iOS 13.0, *) {
            let dataSource = tableView.diffableDataSource(cellType: UITableViewCell.self) { (cell, _, item: RandomItems.Item) in
                cell.textLabel?.text = item.name
            }
            
            store.observeState(\.allItems) { dataSource.appendItems($0, toSection: RandomItems.Section.main) }
        }
        
        else {
            let dataSource = tableView.dataSource(cellType: UITableViewCell.self) { (cell, _, item: RandomItems.Item) in
                cell.textLabel?.text = item.name
            }
            
            store.observeState(\.allItems) { dataSource.appendItems($0).reloadData() }
        }
        
        store.observeState(\.query) { [weak self] in self?.searchController.searchBar.text = $0 }
        tableView.bindDidSelectRow(to: store, action: RandomItems.Action.didSelectRow)
    }
    
}

extension RandomItemsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        store.dispatchAction(.didUpdateSearchQuery(searchController.searchBar.text))
    }
    
}
