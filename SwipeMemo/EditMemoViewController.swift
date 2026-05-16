//
//  EditMemoViewController.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/09.
//

import UIKit

class EditMemoViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextView!
    
    private var presenter: EditMemoPresenterInput!
    private let favoriteToolbar = MemoFavoriteToolbar()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func inject(presenter: EditMemoPresenterInput) {
        self.presenter = presenter
    }
    
    private func setup () {
        textField.text = presenter.initialText()
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.autocapitalizationType = .none
        textField.smartQuotesType = .no
        textField.smartDashesType = .no
        textField.smartInsertDeleteType = .no
        textField.delegate = self
        setupKeyboardToolbar()
        setupFavoriteToolbar()
        
        presentationController?.delegate = self
    }

    private func setupFavoriteToolbar() {
        favoriteToolbar.favoriteDelegate = self
        favoriteToolbar.install(in: view, above: textField)
        updateFavoriteButton(isFavorite: presenter.initialIsFavorite())
    }

    private func setupKeyboardToolbar() {
        textField.inputAccessoryView = KeyboardDoneToolbar(target: self, action: #selector(dismissKeyboard))
    }

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        if let text = self.textField.text, !text.isEmpty {
            presenter.viewWillDisappear(text: text)
        }
        super.viewWillDisappear(true)
    }
}

extension EditMemoViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text,
              let textRange = Range(range, in: currentText)
        else {
            return false
        }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)
        return self.presenter.shouldChangeTextIn(totalWordCount: updatedText.count)
    }
}

extension EditMemoViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        presenter.dismiss()
    }
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        presenter.dismissAfter()
    }
}

extension EditMemoViewController: EditMemoPresenterOutput {
    func updateFavoriteButton(isFavorite: Bool) {
        favoriteToolbar.update(isFavorite: isFavorite)
    }
}

extension EditMemoViewController: MemoFavoriteToolbarDelegate {
    func memoFavoriteToolbarDidTapFavorite(_ toolbar: MemoFavoriteToolbar) {
        presenter.didTapFavoriteButton()
    }
}
