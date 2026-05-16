//
//  EditMemoPresenter.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/10.
//

protocol EditMemoPresenterInput {
    func shouldChangeTextIn (totalWordCount words: Int) -> Bool
    func viewWillDisappear(text: String)
    func dismiss()
    func memo() -> Memo
}

struct EditDataSender {
    var prevScene: EditMemoDismissActionProtocol!
    var memo: Memo!
    
    init(prevScene: EditMemoDismissActionProtocol, memo: Memo) {
        self.prevScene = prevScene
        self.memo = memo
    }
}

protocol EditMemoDismissActionProtocol {
    func viewWillAppear()
    func viewDidAppear()
}

protocol EditMemoPresenterOutput: AnyObject {}

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
    
    func memo() -> Memo {
        return sender.memo
    }
    
    func shouldChangeTextIn (totalWordCount words: Int) -> Bool {
        return self.helper.isNumberOfCharsCorrent(totalWordCount: words)
    }
    
    func viewWillDisappear(text: String) {
        do {
            try self.model.save(memo: sender.memo, text: text)
        } catch StorageError.write(let message) {
            MemoError.pushErrorMessage(message: message)
        } catch {
            fatalError("Unexpected error: \(error).")
        }
    }
}
