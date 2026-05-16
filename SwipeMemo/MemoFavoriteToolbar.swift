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
        static let height: CGFloat = 44
        static let bottomSpacing: CGFloat = 16
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func install(in containerView: UIView, above contentView: UIView, delegate: MemoFavoriteToolbarDelegate, isFavorite: Bool) {
        favoriteDelegate = delegate
        translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(self)
        Self.deactivateBottomConstraints(in: containerView, for: contentView)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -Layout.bottomSpacing),
            heightAnchor.constraint(equalToConstant: Layout.height),
            contentView.bottomAnchor.constraint(equalTo: topAnchor)
        ])
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

    private func setup() {
        favoriteButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(didTapFavoriteButton))
        favoriteButton.tintColor = .systemYellow
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items = [flexibleSpace, favoriteButton]
        update(isFavorite: false)
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
