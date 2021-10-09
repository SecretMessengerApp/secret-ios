
import Cartography

enum EditButtonType: UInt {
    case undo, confirm, cancel
}

protocol InputBarEditViewDelegate: class {
    func inputBarEditView(_ editView: InputBarEditView, didTapButtonWithType buttonType: EditButtonType)
    func inputBarEditViewDidLongPressUndoButton(_ editView: InputBarEditView)
}

final class InputBarEditView: UIView {
    private static var iconButtonTemplate: IconButton {
        let iconButton = IconButton()
        iconButton.setIconColor(.dynamic(scheme: .iconNormal), for: .normal)
        iconButton.setIconColor(.dynamic(scheme: .iconHighlighted), for: .highlighted)
        return iconButton
    }

    let undoButton = InputBarEditView.iconButtonTemplate
    let confirmButton = InputBarEditView.iconButtonTemplate
    let cancelButton = InputBarEditView.iconButtonTemplate
    let iconSize: CGFloat = StyleKitIcon.Size.tiny.rawValue
    
    weak var delegate: InputBarEditViewDelegate?
    
    init() {
        super.init(frame: .zero)
        configureViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func configureViews() {
        [undoButton, confirmButton, cancelButton].forEach {
            addSubview($0)
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
        
        undoButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressUndoButton)))
        undoButton.setIcon(.undo, size: .tiny, for: [])
        undoButton.accessibilityIdentifier = "undoButton"
        confirmButton.setIcon(.checkmark, size: .medium, for: [])
        confirmButton.accessibilityIdentifier = "confirmButton"
        cancelButton.setIcon(.cross, size: .tiny, for: [])
        cancelButton.accessibilityIdentifier = "cancelButton"
        undoButton.isEnabled = false
        confirmButton.isEnabled = false
    }
    
    fileprivate func createConstraints() {
        let margin: CGFloat = 16
        let buttonMargin: CGFloat = margin + iconSize / 2
        constrain(self, undoButton, confirmButton, cancelButton) { view, undoButton, confirmButton, cancelButton in
            align(top: view, undoButton, confirmButton, cancelButton)
            align(bottom: view, undoButton, confirmButton, cancelButton)
            
            undoButton.centerX == view.leading + buttonMargin
            undoButton.width == view.height
            
            confirmButton.centerX == view.centerX
            confirmButton.width == view.height
            cancelButton.centerX == view.trailing - buttonMargin
            cancelButton.width == view.height
        }
    }
    
    @objc func buttonTapped(_ sender: IconButton) {
        let typeBySender = [undoButton: EditButtonType.undo, confirmButton: .confirm, cancelButton: .cancel]
        guard let type = typeBySender[sender] else { return }
        delegate?.inputBarEditView(self, didTapButtonWithType: type)
    }
    
    @objc func didLongPressUndoButton(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        delegate?.inputBarEditViewDidLongPressUndoButton(self)
    }
    
}
