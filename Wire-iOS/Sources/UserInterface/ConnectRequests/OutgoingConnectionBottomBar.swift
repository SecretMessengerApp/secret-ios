

import UIKit
import Cartography


@objc enum OutgoingConnectionBottomBarAction: UInt {
    case cancel, archive
}


 final class OutgoingConnectionViewController: UIViewController {

    private let cancelButton = IconButton(style: .default)
    private let archiveButton = IconButton(style: .default)

    var buttonCallback: ((OutgoingConnectionBottomBarAction) -> Void)?

    init() {
        super.init(nibName: nil, bundle: nil)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        setupCancelButton()
        setupArchiveButton()
        [cancelButton, archiveButton].forEach(view.addSubview)
    }

    private func setupCancelButton() {
        cancelButton.accessibilityLabel = "cancel connection"
        cancelButton.setIcon(.undo, size: .tiny, for: .normal)
        cancelButton.setTitle("profile.cancel_connection_button_title".localized(uppercased: true), for: .normal)
        cancelButton.titleLabel?.font = FontSpec(.small, .light).font!
        cancelButton.setTitleColor(.dynamic(scheme: .title), for: .normal)
        cancelButton.setTitleImageSpacing(24)
        cancelButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    private func setupArchiveButton() {
        archiveButton.accessibilityLabel = "archive connection"
        archiveButton.setIcon(.archive, size: .tiny, for: .normal)
        archiveButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        archiveButton.isHidden = true
    }

    private func createConstraints() {
        constrain(view, cancelButton, archiveButton) { view, cancelButton, archiveButton in
            cancelButton.leading == view.leading + 24
            cancelButton.top == view.top + 12
            cancelButton.bottom == view.bottom - 24
            archiveButton.centerY == cancelButton.centerY
            archiveButton.trailing == view.trailing - 24
        }
    }

    @objc private func buttonTapped(sender: IconButton) {
        switch sender {
        case cancelButton: buttonCallback?(.cancel)
        case archiveButton: buttonCallback?(.archive)
        default: break
        }
    }

}
