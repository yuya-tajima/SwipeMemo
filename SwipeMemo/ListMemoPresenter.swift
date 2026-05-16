//
//  ListMemoPresenter.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/09.
//

import UIKit

protocol ListMemoPresenterInput {
    func didTapDeleteButton(forRow row: Int, indexPath: IndexPath)
    func didSwipeLeft()
    var numberOfMemos: Int { get }
    func memo(forRow row:Int) -> Memo
    func moveMemo(from sourceRow: Int, to destinationRow: Int) -> Bool
    func viewWillAppear()
    func pullDown()
}

protocol ListMemoPresenterOutput: AnyObject {
    func reloadMemo()
    func transitionToCreate()
    func transitionToSettings()
}

final class ListMemoPresenter: ListMemoPresenterInput {
    
    private weak var view: ListMemoPresenterOutput!
    private var model: ListMemoModelInput
    
    private var memos: [Memo] = []
    
    var numberOfMemos: Int {
        return memos.count
    }

    init(view: ListMemoPresenterOutput, model: ListMemoModelInput) {
        self.view  = view
        self.model = model
    }
    
    func memo(forRow row: Int) -> Memo {
        return memos[row]
    }
    
    private func fetchMemo() {
        do {
            try memos = self.model.fetchAll()
        } catch {
            memos = []
            handleError(error)
        }
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

    func didTapDeleteButton(forRow row: Int, indexPath at: IndexPath) {
        let memo = memo(forRow: row)
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

    func moveMemo(from sourceRow: Int, to destinationRow: Int) -> Bool {
        guard sourceRow != destinationRow else {
            return true
        }

        guard memos.indices.contains(sourceRow),
              memos.indices.contains(destinationRow) else {
            fatalError("Invalid memo move: source \(sourceRow), destination \(destinationRow), count \(memos.count).")
        }

        let movedMemo = memos.remove(at: sourceRow)
        memos.insert(movedMemo, at: destinationRow)

        do {
            try model.updateDisplayOrder(memos: memos)
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
