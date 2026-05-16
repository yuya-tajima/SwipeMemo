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
}

protocol CreateMemoPresenterOutput: AnyObject {
    func transitionToNextInput(storyboardID: String)
    func transitionToList()
}

struct CreateMemoPresenter: CreateMemoPresenterInput {
    
    private weak var view: CreateMemoPresenterOutput!
    private var model: CreateMemoModelInput
    private var helper: InputMemoConstraintsProtocol
    
    init(view: CreateMemoPresenterOutput, model: CreateMemoModelInput, helper: InputMemoConstraintsProtocol) {
        self.view  = view
        self.model = model
        self.helper = helper
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
            try self.model.save(text: normalizedText)
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
