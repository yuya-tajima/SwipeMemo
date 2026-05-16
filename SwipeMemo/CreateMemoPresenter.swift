//
//  CreateMemoPresenter.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/10.
//

protocol CreateMemoPresenterInput {
    func didLeftSwipe(storyboardID: String)
    func didDownSwipe()
    func shouldChangeTextIn (totalWordCount words: Int) -> Bool
    func viewWillDisappear(text: String)
    func initialIsFavorite() -> Bool
    mutating func didTapFavoriteButton()
}

protocol CreateMemoPresenterOutput: AnyObject {
    func transitionToNextInput(storyboardID: String)
    func transitionToList()
    func updateFavoriteButton(isFavorite: Bool)
}

struct CreateMemoPresenter: CreateMemoPresenterInput {
    
    private weak var view: CreateMemoPresenterOutput!
    private var model: CreateMemoModelInput
    private var helper: InputMemoConstraintsProtocol
    private var isFavorite = false
    
    init(view: CreateMemoPresenterOutput, model: CreateMemoModelInput, helper: InputMemoConstraintsProtocol) {
        self.view  = view
        self.model = model
        self.helper = helper
    }
    
    func shouldChangeTextIn (totalWordCount words: Int) -> Bool {
        return self.helper.isNumberOfCharsCorrent(totalWordCount: words)
    }

    func initialIsFavorite() -> Bool {
        return isFavorite
    }

    mutating func didTapFavoriteButton() {
        isFavorite.toggle()
        view.updateFavoriteButton(isFavorite: isFavorite)
    }
    
    func viewWillDisappear(text: String) {
        let normalizedText = self.helper.normalizedTextForSaving(text)
        guard !normalizedText.isEmpty else {
            return
        }

        do {
            try self.model.save(text: normalizedText, isFavorite: isFavorite)
        } catch StorageError.write(let message) {
            MemoError.pushErrorMessage(message: message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
    
    func didLeftSwipe(storyboardID id: String) {
        self.view.transitionToNextInput(storyboardID: id)
    }
    
    func didDownSwipe() {
        self.view.transitionToList()
    }
}
