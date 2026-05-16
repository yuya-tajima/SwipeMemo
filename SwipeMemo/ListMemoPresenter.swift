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

    private struct MemoSection {
        enum Kind: Equatable {
            case favorite
            case regular
        }

        let kind: Kind
        var memos: [Memo]

        var isFavorite: Bool {
            switch kind {
            case .favorite:
                return true
            case .regular:
                return false
            }
        }

        var title: String? {
            switch kind {
            case .favorite:
                return NSLocalizedString("memo_list_favorites_section_title", comment: "")
            case .regular:
                return NSLocalizedString("memo_list_regular_section_title", comment: "")
            }
        }

        var moveFailureDescription: String {
            switch kind {
            case .favorite:
                return "favorite memo"
            case .regular:
                return "regular memo"
            }
        }
    }

    private weak var view: ListMemoPresenterOutput!
    private var model: ListMemoModelInput
    
    private var sections: [MemoSection] = []
    
    var numberOfSections: Int {
        return sections.count
    }

    init(view: ListMemoPresenterOutput, model: ListMemoModelInput) {
        self.view  = view
        self.model = model
    }

    private static func makeSections(from memos: [Memo]) -> [MemoSection] {
        let favoriteMemos = memos.filter { $0.isFavorite }
        let regularMemos = memos.filter { !$0.isFavorite }
        var sections: [MemoSection] = []
        if !favoriteMemos.isEmpty {
            sections.append(MemoSection(kind: .favorite, memos: favoriteMemos))
        }
        if !regularMemos.isEmpty {
            sections.append(MemoSection(kind: .regular, memos: regularMemos))
        }
        return sections
    }
    
    func numberOfMemos(in section: Int) -> Int {
        return memoSection(at: section).memos.count
    }

    func memo(at indexPath: IndexPath) -> Memo {
        return memoSection(at: indexPath.section).memos[indexPath.row]
    }

    func titleForSection(_ section: Int) -> String? {
        let memoSection = memoSection(at: section)
        if memoSection.kind == .regular && !hasFavoriteSection {
            return nil
        }
        return memoSection.title
    }
    
    private func fetchMemo() {
        do {
            let memos = try self.model.fetchAll()
            sections = Self.makeSections(from: memos)
        } catch {
            sections = []
            handleError(error)
        }
    }

    private var hasFavoriteSection: Bool {
        return sections.contains { $0.kind == .favorite }
    }

    private func memoSection(at section: Int) -> MemoSection {
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

        let movedSection = memoSection(at: sourceIndexPath.section)
        guard movedSection.memos.indices.contains(sourceIndexPath.row),
              movedSection.memos.indices.contains(destinationIndexPath.row) else {
            fatalError("Invalid \(movedSection.moveFailureDescription) move: source \(sourceIndexPath.row), destination \(destinationIndexPath.row), count \(movedSection.memos.count).")
        }

        let movedMemo = sections[sourceIndexPath.section].memos.remove(at: sourceIndexPath.row)
        sections[sourceIndexPath.section].memos.insert(movedMemo, at: destinationIndexPath.row)
        let movedAreaMemos = sections[sourceIndexPath.section].memos

        do {
            try model.updateDisplayOrder(memos: movedAreaMemos, isFavorite: movedSection.isFavorite)
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
