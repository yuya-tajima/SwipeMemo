//
//  MemoFavoriteToolbar.swift
//  SwipeMemo
//

import UIKit

protocol MemoFavoriteToolbarDelegate: AnyObject {
    func memoFavoriteToolbarDidTapFavorite(_ toolbar: MemoFavoriteToolbar)
}

final class MemoFavoriteToolbar: UIToolbar {

    weak var favoriteDelegate: MemoFavoriteToolbarDelegate?

    private var favoriteButton: UIBarButtonItem!
    private enum Layout {
        static let size: CGFloat = 44
        static let verticalSpacing: CGFloat = 8
        static let contentBottomInset: CGFloat = 108
        static let indicatorBottomInset: CGFloat = 108
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func install(
        in containerView: UIView,
        overlaying contentView: UIView,
        above doneToolbar: UIView,
        delegate: MemoFavoriteToolbarDelegate,
        isFavorite: Bool
    ) {
        favoriteDelegate = delegate
        translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(self)
        Self.deactivateBottomConstraints(in: containerView, for: contentView)

        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: doneToolbar.trailingAnchor),
            bottomAnchor.constraint(equalTo: doneToolbar.topAnchor, constant: -Layout.verticalSpacing),
            widthAnchor.constraint(equalToConstant: Layout.size),
            heightAnchor.constraint(equalToConstant: Layout.size),
            contentView.bottomAnchor.constraint(equalTo: containerView.keyboardLayoutGuide.topAnchor)
        ])
        Self.addOverlayInsets(to: contentView)
        update(isFavorite: isFavorite)
    }

    func update(isFavorite: Bool) {
        let imageName = isFavorite ? "star.fill" : "star"
        favoriteButton.image = UIImage(systemName: imageName)
        favoriteButton.accessibilityLabel = NSLocalizedString(
            isFavorite ? "favorite_button_remove_accessibility_label" : "favorite_button_add_accessibility_label",
            comment: ""
        )
    }

    func scrollSelectionAboveControls(in textView: UITextView) {
        guard textView.isFirstResponder,
              let selectedTextRange = textView.selectedTextRange,
              selectedTextRange.isEmpty
        else {
            return
        }

        var protectedCaretRect = textView.caretRect(for: selectedTextRange.end)
        protectedCaretRect.size.height += Layout.contentBottomInset
        textView.scrollRectToVisible(protectedCaretRect, animated: false)
    }

    private func setup() {
        favoriteButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(didTapFavoriteButton))
        favoriteButton.tintColor = .systemYellow
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items = [flexibleSpace, favoriteButton]
        clipsToBounds = true
        layer.cornerRadius = Layout.size / 2
        update(isFavorite: false)
    }

    private static func addOverlayInsets(to contentView: UIView) {
        guard let scrollView = contentView as? UIScrollView else {
            return
        }

        scrollView.contentInset.bottom = max(scrollView.contentInset.bottom, Layout.contentBottomInset)
        scrollView.verticalScrollIndicatorInsets.bottom = max(
            scrollView.verticalScrollIndicatorInsets.bottom,
            Layout.indicatorBottomInset
        )
    }

    private static func deactivateBottomConstraints(in containerView: UIView, for contentView: UIView) {
        containerView.constraints
            .filter { constraint in
                let firstView = constraint.firstItem as? UIView
                let secondView = constraint.secondItem as? UIView
                let containsContentView = firstView === contentView ||
                    secondView === contentView
                let containsBottom = constraint.firstAttribute == .bottom ||
                    constraint.secondAttribute == .bottom
                return containsContentView && containsBottom
            }
            .forEach { $0.isActive = false }
    }

    @objc private func didTapFavoriteButton() {
        favoriteDelegate?.memoFavoriteToolbarDidTapFavorite(self)
    }
}
