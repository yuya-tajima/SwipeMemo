//
//  KeyboardDoneToolbar.swift
//  SwipeMemo
//

import UIKit

final class KeyboardDoneToolbar: UIToolbar {

    init(target: AnyObject, action: Selector) {
        super.init(frame: .zero)
        setup(target: target, action: action)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup(target: AnyObject, action: Selector) {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: action)

        items = [flexibleSpace, doneButton]
        sizeToFit()
    }
}
