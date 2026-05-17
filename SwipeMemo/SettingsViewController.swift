//
//  SettingsViewController.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/16.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        versionLabel.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        let downSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.didSwipe(_:))
        )
        downSwipe.direction = .down
        self.view.addGestureRecognizer(downSwipe)

        let leftSwipe = UISwipeGestureRecognizer(
            target: self,
            action: #selector(self.didSwipe(_:))
        )
        leftSwipe.direction = .left
        self.view.addGestureRecognizer(leftSwipe)
    }

    @objc func didSwipe(_ sender: UISwipeGestureRecognizer) {

        let transition:CATransition = CATransition()
        transition.duration = 0.25
        transition.type = .push

        switch sender.direction {
        case .down:
            transition.subtype = .fromTop
        case .left:
            transition.subtype = .fromRight
        default:
            break
        }
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
}
