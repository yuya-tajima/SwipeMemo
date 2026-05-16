//
//  CreateMemoViewController.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/02.
//

import UIKit

class CreateMemoViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    private var listViewController: ListMemoViewController!
    private var firstViewController: CreateMemoViewController!
    private var secondViewController: CreateMemoViewController!
    
    private var presenter: CreateMemoPresenterInput!
    private let favoriteToolbar = MemoFavoriteToolbar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func inject(presenter: CreateMemoPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if MemoError.exists() {
            let dialog = UIAlertController(title: "Error", message: MemoError.popErrorMessage(), preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(dialog, animated: true, completion: nil)
        }
        self.textField.becomeFirstResponder()
    }
    
    private func setup() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

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

        let leftSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.didSwipe(_:))
        )
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)

        let downSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.didSwipe(_:))
        )
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)
        
        let model = CreateMemoModel()
        let helper = InputMemoHelper()

        listViewController = storyboard!.instantiateViewController(withIdentifier: "List") as? ListMemoViewController
        listViewController.inject(
            presenter: ListMemoPresenter(
                view: listViewController,
                model: ListMemoModel()
            )
        )
        
        firstViewController = storyboard!.instantiateViewController(withIdentifier: "FirstInput") as? CreateMemoViewController
        firstViewController.inject(
            presenter: CreateMemoPresenter(
                view: firstViewController,
                model: model,
                helper: helper
            )
        )
        
        secondViewController = storyboard!.instantiateViewController(withIdentifier: "SecondInput") as? CreateMemoViewController
        secondViewController.inject(
            presenter: CreateMemoPresenter(
                view: secondViewController,
                model: model,
                helper: helper
            )
        )
    }

    private func setupFavoriteToolbar() {
        favoriteToolbar.favoriteDelegate = self
        favoriteToolbar.install(in: view, above: textField)
        favoriteToolbar.update(isFavorite: presenter.initialIsFavorite())
    }

    private func setupKeyboardToolbar() {
        textField.inputAccessoryView = KeyboardDoneToolbar(target: self, action: #selector(dismissKeyboard))
    }

    @objc private func dismissKeyboard() {
        textField.resignFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let text = self.textField.text, !text.isEmpty {
            self.presenter.viewWillDisappear(text: text)
        }
        super.viewWillDisappear(true)
    }
    
    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            let storyboardID = self.restorationIdentifier!
            presenter.didLeftSwipe(storyboardID: storyboardID)
        case .down:
            presenter.didDownSwipe()
        default:
            break
        }
    }
}

extension CreateMemoViewController: UITextViewDelegate {
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

extension CreateMemoViewController: CreateMemoPresenterOutput {

    func updateFavoriteButton(isFavorite: Bool) {
        favoriteToolbar.update(isFavorite: isFavorite)
    }
    
    func transitionToNextInput(storyboardID: String) {
        var controllerStack: [UIViewController] = [listViewController]
        
        if storyboardID == "FirstInput" {
            controllerStack += [firstViewController, secondViewController]
        } else {
            controllerStack += [secondViewController, firstViewController]
        }
        
        let transition:CATransition = CATransition()
        transition.duration = 0.1
        transition.type = .push
        transition.subtype = .fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.setViewControllers(controllerStack, animated: false)
    }
    
    func transitionToList() {
        let controllerStack: [UIViewController] = [listViewController]
        let transition:CATransition = CATransition()
        transition.duration = 0.1
        transition.type = .push
        transition.subtype = .fromTop
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.setViewControllers(controllerStack, animated: false)
    }
}

extension CreateMemoViewController: MemoFavoriteToolbarDelegate {
    func memoFavoriteToolbarDidTapFavorite(_ toolbar: MemoFavoriteToolbar) {
        presenter.didTapFavoriteButton()
    }
}
