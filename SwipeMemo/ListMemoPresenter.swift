//
//  ListMemoPresenter.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/09.
//

import UIKit

protocol ListMemoPresenterInput {
    func didTapDeleteButton(at indexPath: IndexPath)
    func didSwipeLeft()
    var numberOfSections: Int { get }
    func numberOfMemos(in section: Int) -> Int
    func memo(at indexPath: IndexPath) -> Memo
    func titleForSection(_ section: Int) -> String?
    func moveMemo(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Bool
    func viewWillAppear()
    func pullDown()
}

protocol ListMemoPresenterOutput: AnyObject {
    func reloadMemo()
    func transitionToCreate()
    func transitionToSettings()
}

final class ListMemoPresenter: ListMemoPresenterInput {

    private enum MemoSection {
        case favorite
        case regular
    }
    
    private weak var view: ListMemoPresenterOutput!
    private var model: ListMemoModelInput
    
    private var favoriteMemos: [Memo] = []
    private var regularMemos: [Memo] = []
    
    var numberOfSections: Int {
        return sections.count
    }

    init(view: ListMemoPresenterOutput, model: ListMemoModelInput) {
        self.view  = view
        self.model = model
    }

    private var sections: [MemoSection] {
        var sections: [MemoSection] = []
        if !favoriteMemos.isEmpty {
            sections.append(.favorite)
        }
        if !regularMemos.isEmpty {
            sections.append(.regular)
        }
        return sections
    }
    
    func numberOfMemos(in section: Int) -> Int {
        switch memoSection(at: section) {
        case .favorite:
            return favoriteMemos.count
        case .regular:
            return regularMemos.count
        }
    }

    func memo(at indexPath: IndexPath) -> Memo {
        switch memoSection(at: indexPath.section) {
        case .favorite:
            return favoriteMemos[indexPath.row]
        case .regular:
            return regularMemos[indexPath.row]
        }
    }

    func titleForSection(_ section: Int) -> String? {
        switch memoSection(at: section) {
        case .favorite:
            return NSLocalizedString("memo_list_favorites_section_title", comment: "")
        case .regular:
            guard !favoriteMemos.isEmpty else {
                return nil
            }
            return NSLocalizedString("memo_list_regular_section_title", comment: "")
        }
    }
    
    private func fetchMemo() {
        do {
            let memos = try self.model.fetchAll()
            favoriteMemos = memos.filter { $0.isFavorite }
            regularMemos = memos.filter { !$0.isFavorite }
        } catch {
            favoriteMemos = []
            regularMemos = []
            handleError(error)
        }
    }

    private func memoSection(at section: Int) -> MemoSection {
        let sections = self.sections
        guard sections.indices.contains(section) else {
            fatalError("Invalid memo section: \(section), count \(sections.count).")
        }
        return sections[section]
    }

    private func handleError(_ error: Error) {
        switch error {
        case StorageError.write(let message),
             StorageError.read(let message):
            MemoError.pushErrorMessage(message: message)
        default:
            fatalError("Unexpected error: \(error).")
        }
    }
    
    func viewWillAppear() {
        fetchMemo()
        view.reloadMemo()
    }
    
    func pullDown() {
        view.transitionToCreate()
    }

    func didTapDeleteButton(at indexPath: IndexPath) {
        let memo = memo(at: indexPath)
        do {
            try self.model.delete(memo: memo)
            fetchMemo()
            view.reloadMemo()
        } catch {
            handleError(error)
            fetchMemo()
            view.reloadMemo()
        }
    }

    func moveMemo(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath != destinationIndexPath else {
            return true
        }

        guard sections.indices.contains(sourceIndexPath.section),
              sections.indices.contains(destinationIndexPath.section) else {
            fatalError("Invalid memo move section: source \(sourceIndexPath.section), destination \(destinationIndexPath.section), count \(sections.count).")
        }

        guard sourceIndexPath.section == destinationIndexPath.section else {
            fetchMemo()
            view.reloadMemo()
            return false
        }

        let movedAreaMemos: [Memo]
        let isFavoriteMove: Bool
        switch memoSection(at: sourceIndexPath.section) {
        case .favorite:
            guard favoriteMemos.indices.contains(sourceIndexPath.row),
                  favoriteMemos.indices.contains(destinationIndexPath.row) else {
                fatalError("Invalid favorite memo move: source \(sourceIndexPath.row), destination \(destinationIndexPath.row), count \(favoriteMemos.count).")
            }
            let movedMemo = favoriteMemos.remove(at: sourceIndexPath.row)
            favoriteMemos.insert(movedMemo, at: destinationIndexPath.row)
            movedAreaMemos = favoriteMemos
            isFavoriteMove = true
        case .regular:
            guard regularMemos.indices.contains(sourceIndexPath.row),
                  regularMemos.indices.contains(destinationIndexPath.row) else {
                fatalError("Invalid regular memo move: source \(sourceIndexPath.row), destination \(destinationIndexPath.row), count \(regularMemos.count).")
            }
            let movedMemo = regularMemos.remove(at: sourceIndexPath.row)
            regularMemos.insert(movedMemo, at: destinationIndexPath.row)
            movedAreaMemos = regularMemos
            isFavoriteMove = false
        }

        do {
            try model.updateDisplayOrder(memos: movedAreaMemos, isFavorite: isFavoriteMove)
            fetchMemo()
            return true
        } catch {
            handleError(error)
            fetchMemo()
            view.reloadMemo()
            return false
        }
    }

    func didSwipeLeft() {
        view.transitionToSettings()
    }
}
