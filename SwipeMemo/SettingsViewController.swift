//
//  SettingsViewController.swift
//  SwipeMemo
//
//  Created by 優也田島 on 2022/07/16.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    private var colorControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = Theme.color
    }

    private func setup() {

        versionLabel.text = "1.0"

        colorControl = UISegmentedControl(items: MainColor.allCases.map { $0.title })
        colorControl.selectedSegmentIndex = Theme.current.rawValue
        colorControl.translatesAutoresizingMaskIntoConstraints = false
        colorControl.addTarget(self, action: #selector(colorChanged(_:)), for: .valueChanged)
        view.addSubview(colorControl)
        NSLayoutConstraint.activate([
            colorControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            colorControl.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 20)
        ])

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

    @objc private func colorChanged(_ sender: UISegmentedControl) {
        guard let newColor = MainColor(rawValue: sender.selectedSegmentIndex) else { return }
        Theme.current = newColor
        view.backgroundColor = Theme.color
    }
}
