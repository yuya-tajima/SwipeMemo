//
//  KeyboardDoneToolbar.swift
//  SwipeMemo
//

import UIKit

final class KeyboardDoneToolbar: UIToolbar {

    private enum Layout {
        static let size: CGFloat = 44
        static let trailingSpacing: CGFloat = 16
        static let bottomSpacing: CGFloat = 12
    }

    init(target: AnyObject, action: Selector) {
        super.init(frame: .zero)
        setup(target: target, action: action)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func install(in containerView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(self)

        NSLayoutConstraint.activate([
            trailingAnchor.constraint(
                equalTo: containerView.safeAreaLayoutGuide.trailingAnchor,
                constant: -Layout.trailingSpacing
            ),
            bottomAnchor.constraint(
                equalTo: containerView.keyboardLayoutGuide.topAnchor,
                constant: -Layout.bottomSpacing
            ),
            widthAnchor.constraint(equalToConstant: Layout.size),
            heightAnchor.constraint(equalToConstant: Layout.size)
        ])
    }

    private func setup(target: AnyObject, action: Selector) {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: action)

        items = [flexibleSpace, doneButton]
        clipsToBounds = true
        layer.cornerRadius = Layout.size / 2
        sizeToFit()
    }
}
