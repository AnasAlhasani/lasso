//
// ==----------------------------------------------------------------------== //
//
//  TableViewDelegateProxy.swift
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

public final class TableViewDelegateProxy: NSObject {
    public typealias WillDisplayCellAction = (UITableViewCell, IndexPath) -> Void
    public typealias WillDisplayHeaderViewAction = (UIView, Int) -> Void
    public typealias WillDisplayFooterViewAction = (UIView, Int) -> Void
    public typealias DidEndDisplayingCellAction = (UITableViewCell, IndexPath) -> Void
    public typealias DidEndDisplayingHeaderViewAction = (UIView, Int) -> Void
    public typealias DidEndDisplayingFooterViewAction = (UIView, Int) -> Void
    public typealias DidHighlightRowAction = (IndexPath) -> Void
    public typealias DidUnhighlightRowAction = (IndexPath) -> Void
    public typealias DidSelectRowAction = (IndexPath) -> Void
    public typealias DidDeselectRowAction = (IndexPath) -> Void
    public typealias WillBeginEditingRowAction = (IndexPath) -> Void
    public typealias DidEndEditingRowAction = (IndexPath) -> Void

    public var willDisplayCell: WillDisplayCellAction?
    public var willDisplayHeaderView: WillDisplayHeaderViewAction?
    public var willDisplayFooterView: WillDisplayFooterViewAction?
    public var didEndDisplayingCell: DidEndDisplayingCellAction?
    public var didEndDisplayingHeaderView: DidEndDisplayingHeaderViewAction?
    public var didEndDisplayingFooterView: DidEndDisplayingFooterViewAction?
    public var didHighlightRow: DidHighlightRowAction?
    public var didUnhighlightRow: DidUnhighlightRowAction?
    public var didSelectRow: DidSelectRowAction?
    public var didDeselectRow: DidDeselectRowAction?
    public var willBeginEditingRow: WillBeginEditingRowAction?
    public var didEndEditingRow: DidEndEditingRowAction?
    
    @discardableResult
    public func setDelegate(to tableView: UITableView) -> Self {
        tableView.delegate = self
        return self
    }
}

extension TableViewDelegateProxy: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayCell?(cell, indexPath)
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        willDisplayHeaderView?(view, section)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        willDisplayFooterView?(view, section)
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        didEndDisplayingCell?(cell, indexPath)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        didEndDisplayingHeaderView?(view, section)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        didEndDisplayingFooterView?(view, section)
    }

    public func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        didHighlightRow?(indexPath)
    }

    public func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        didUnhighlightRow?(indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow?(indexPath)
    }

    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        didDeselectRow?(indexPath)
    }

    public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        willBeginEditingRow?(indexPath)
    }

    public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }

        didEndEditingRow?(indexPath)
    }
}


extension UITableView {
    public func willDisplayCell(_ action: @escaping TableViewDelegateProxy.WillDisplayCellAction) {
        delegateProxy.willDisplayCell = action
    }
    
    public func willDisplayHeaderView(_ action: @escaping TableViewDelegateProxy.WillDisplayHeaderViewAction) {
        delegateProxy.willDisplayHeaderView = action
    }
    
    public func willDisplayFooterView(_ action: @escaping TableViewDelegateProxy.WillDisplayFooterViewAction) {
        delegateProxy.willDisplayFooterView = action
    }
    
    public func didEndDisplayingCell(_ action: @escaping TableViewDelegateProxy.DidEndDisplayingCellAction) {
        delegateProxy.didEndDisplayingCell = action
    }
    
    public func didEndDisplayingHeaderView(_ action: @escaping TableViewDelegateProxy.DidEndDisplayingHeaderViewAction) {
        delegateProxy.didEndDisplayingHeaderView = action
    }
    
    public func didEndDisplayingFooterView(_ action: @escaping TableViewDelegateProxy.DidEndDisplayingFooterViewAction) {
        delegateProxy.didEndDisplayingFooterView = action
    }
    
    public func didHighlightRow(_ action: @escaping TableViewDelegateProxy.DidHighlightRowAction) {
        delegateProxy.didHighlightRow = action
    }
    
    public func didUnhighlightRow(_ action: @escaping TableViewDelegateProxy.DidUnhighlightRowAction) {
        delegateProxy.didUnhighlightRow = action
    }
    
    public func didSelectRow(_ action: @escaping TableViewDelegateProxy.DidSelectRowAction) {
        delegateProxy.didSelectRow = action
    }
    
    public func didDeselectRow(_ action: @escaping TableViewDelegateProxy.DidDeselectRowAction) {
        delegateProxy.didDeselectRow = action
    }
    
    public func willBeginEditingRow(_ action: @escaping TableViewDelegateProxy.WillBeginEditingRowAction) {
        delegateProxy.willBeginEditingRow = action
    }
    
    public func didEndEditingRow(_ action: @escaping TableViewDelegateProxy.DidEndEditingRowAction) {
        delegateProxy.didEndEditingRow = action
    }
    
    private var delegateProxy: TableViewDelegateProxy {
        let proxy = TableViewDelegateProxy().setDelegate(to: self)
        holdReference(to: proxy)
        return proxy
    }
}

extension UITableView {
    public func bindWillDisplayCell<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (UITableViewCell, IndexPath) -> Target.Action
    ) {
        willDisplayCell { [weak target] in target?.dispatchAction(action($0, $1)) }
    }
    
    public func bindDidEndDisplayingCell<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (UITableViewCell, IndexPath) -> Target.Action
    ) {
        didEndDisplayingCell { [weak target] in target?.dispatchAction(action($0, $1)) }
    }
    
    public func bindWillDisplayHeaderView<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (UIView, Int) -> Target.Action
    ) {
        willDisplayHeaderView { [weak target] in target?.dispatchAction(action($0, $1)) }
    }
    
    public func bundWillDisplayFooterView<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (UIView, Int) -> Target.Action
    ) {
        willDisplayFooterView { [weak target] in target?.dispatchAction(action($0, $1)) }
    }
    
    public func bindDidEndDisplayingHeaderView<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (UIView, Int) -> Target.Action
    ) {
        didEndDisplayingHeaderView { [weak target] in target?.dispatchAction(action($0, $1)) }
    }
    
    public func bindDidEndDisplayingFooterView<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (UIView, Int) -> Target.Action
    ) {
        didEndDisplayingFooterView { [weak target] in target?.dispatchAction(action($0, $1)) }
    }
    
    public func bindDidHighlightRow<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (IndexPath) -> Target.Action
    ) {
        didHighlightRow { [weak target] in target?.dispatchAction(action($0)) }
    }
    
    public func bindDidUnhighlightRow<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (IndexPath) -> Target.Action
    ) {
        didUnhighlightRow { [weak target] in target?.dispatchAction(action($0)) }
    }
    
    public func bindDidSelectRow<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (IndexPath) -> Target.Action
    ) {
        didSelectRow { [weak target] in target?.dispatchAction(action($0)) }
    }
    
    public func bindDidDeselectRow<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (IndexPath) -> Target.Action
    ) {
        didDeselectRow { [weak target] in target?.dispatchAction(action($0)) }
    }
    
    public func bindWillBeginEditingRow<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (IndexPath) -> Target.Action
    ) {
        willBeginEditingRow { [weak target] in target?.dispatchAction(action($0)) }
    }
    
    public func bindDidEndEditingRow<Target: ActionDispatchable>(
        to target: Target,
        action: @escaping (IndexPath) -> Target.Action
    ) {
        didEndEditingRow { [weak target] in target?.dispatchAction(action($0)) }
    }
}
