//
//  InputViewController.swift
//  EphemeralMemo
//
//  Created by 優也田島 on 2022/07/02.
//

import UIKit
import RealmSwift

class InputViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    var listViewController: UIViewController!
    var firstViewController: UIViewController!
    var sedondViewController: UIViewController!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.textContainerInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        textField.delegate = self

        self.navigationController!.setNavigationBarHidden(true, animated: false)

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

        listViewController   = storyboard!.instantiateViewController(withIdentifier: "List")
        firstViewController  = storyboard!.instantiateViewController(withIdentifier: "FirstInput")
        sedondViewController = storyboard!.instantiateViewController(withIdentifier: "SecondInput")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if let text = self.textField.text, !text.isEmpty {
            try! realm.write {
                let memo = Memo()
                memo.contents = text
                memo.date = Date()
                self.realm.add(memo, update: .modified)
            }
        }
        
        super.viewWillDisappear(true)
    }

    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {
        
        let storyboardID = self.restorationIdentifier!
        var controllerStack: [UIViewController] = [listViewController]

        switch sender.direction {
        case .left:
            if storyboardID == "FirstInput" {
                controllerStack += [firstViewController, sedondViewController]
            } else {
                controllerStack += [sedondViewController, firstViewController]
            }
        default:
            break
        }
        
        let transition:CATransition = CATransition()
        transition.duration = 0.1
        transition.type = .push
        transition.subtype = .fromRight
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController!.setViewControllers(controllerStack, animated: false)
    }
}

extension InputViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let maxWordsNumber = 150
        let maxLinesNumber = 10
        
        let totalWordCount    = textView.text.count + (text.count - range.length)
        
        let currentLineCount  = textView.text.components(separatedBy: .newlines).count
        let newLineCount      = text.components(separatedBy: .newlines).count - 1
        let totalLineCount    = currentLineCount + newLineCount
        
        return (totalWordCount <= maxWordsNumber) && (totalLineCount <= maxLinesNumber)
    }
}
