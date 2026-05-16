//
//  EditMemoPresenter.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/10.
//

import RealmSwift

protocol EditMemoPresenterInput {
    func shouldChangeTextIn (totalWordCount words: Int) -> Bool
    func viewWillDisappear(text: String)
    func dismiss()
    func dismissAfter()
    func initialText() -> String
    func initialIsFavorite() -> Bool
    func didTapFavoriteButton()
}

struct EditDataSender {
    let prevScene: EditMemoDismissActionProtocol
    let memoID: ObjectId
    let initialText: String
    let initialIsFavorite: Bool
    
    init(prevScene: EditMemoDismissActionProtocol, memoID: ObjectId, initialText: String, initialIsFavorite: Bool) {
        self.prevScene = prevScene
        self.memoID = memoID
        self.initialText = initialText
        self.initialIsFavorite = initialIsFavorite
    }
}

protocol EditMemoDismissActionProtocol {
    func viewWillAppear()
    func viewDidAppear()
}

protocol EditMemoPresenterOutput: AnyObject {
    func updateFavoriteButton(isFavorite: Bool)
}

struct EditMemoPresenter: EditMemoPresenterInput {


    private weak var view: EditMemoPresenterOutput!
    private var model: EditMemoModelInput
    private var helper: InputMemoConstraintsProtocol
    private var sender: EditDataSender

    init(view: EditMemoPresenterOutput, model: EditMemoModelInput, helper: InputMemoConstraintsProtocol, sender: EditDataSender) {
        self.view  = view
        self.model = model
        self.helper = helper
        self.sender = sender
    }
    
    func dismiss() {
        sender.prevScene.viewWillAppear()
    }
    
    func dismissAfter() {
        sender.prevScene.viewDidAppear()
    }
    
    func initialText() -> String {
        return sender.initialText
    }

    func initialIsFavorite() -> Bool {
        return sender.initialIsFavorite
    }
    
    func shouldChangeTextIn (totalWordCount words: Int) -> Bool {
        return self.helper.isNumberOfCharsCorrent(totalWordCount: words)
    }
    
    func viewWillDisappear(text: String) {
        let normalizedText = self.helper.normalizedTextForSaving(text)
        guard !normalizedText.isEmpty else {
            return
        }

        do {
            try self.model.save(memoID: sender.memoID, text: normalizedText)
        } catch StorageError.write(let message) {
            MemoError.pushErrorMessage(message: message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }

    func didTapFavoriteButton() {
        do {
            let isFavorite = try self.model.toggleFavorite(memoID: sender.memoID)
            view.updateFavoriteButton(isFavorite: isFavorite)
        } catch StorageError.write(let message) {
            MemoError.pushErrorMessage(message: message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
