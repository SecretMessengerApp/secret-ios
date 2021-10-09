

import Foundation

final class InputBarIndicateButton: IconButton {
    
    enum Status {
        case up
        case down
        case markdown
        case expression
    }
    
    fileprivate var status: Status = .up {
        didSet {
            updateIcon()
        }
    }
    
    private func updateIcon() {
        switch status {
        case .up:
            let image = StyleKitIcon.upArrow.makeImage(size: .tiny, color: .dynamic(scheme: .iconNormal))
            setImage(image.withColor(.dynamic(scheme: .iconNormal)), for: .normal)
            
        case .down:
            let image = StyleKitIcon.downArrow.makeImage(size: .tiny, color: .dynamic(scheme: .iconNormal))
            setImage(image.withColor(.dynamic(scheme: .iconNormal)), for: .normal)
            
        case .markdown:
            let image = UIImage(named: "markdown_selected")
            setImage(image, for: .normal)
            
        case .expression:
            let image = UIImage(named: "inputbar_expression_h")
            setImage(image, for: .normal)
        }
    }
}

extension ConversationInputBarViewController {
    
    func configureIndicateButtonStatusToMarkdown() {
        indicateButton.status = .markdown
    }
    
    func configureIndicateButtonStatusToExpression() {
        indicateButton.status = .expression
    }
    
    func configureIndicateButton() {
        indicateButton.addTarget(self, action: #selector(indicateButtonTapped), for: .touchUpInside)
        indicateButton.status = .up
    }
    
    func updateIndicateButton() {
        if inputBar.isEditing, indicateButton.status != .down {
            indicateButton.status = .down
        }
        indicateButton.isEnabled = !inputBar.isEditing
    }
    
    @objc func indicateButtonTapped(_ sender: InputBarIndicateButton) {

        switch sender.status {
        case .up:
            sender.status = .down
            inputBar.isButtonContainerHidden = false
            inputBar.setInputBarState(.writing(ephemeral: ephemeralState), animated: true)
            
        case .down:
            inputBar.isButtonContainerHidden = true
            sender.status = .up
            inputBar.setInputBarState(.writing(ephemeral: ephemeralState), animated: true)
            
        case .markdown:
            if inputBar.isMarkingDown {
                sender.status = .down
                inputBar.setInputBarState(.writing(ephemeral: ephemeralState), animated: true)
            } else {
                sender.status = .markdown
                inputBar.textView.becomeFirstResponder()
                inputBar.setInputBarState(.markingDown(ephemeral: ephemeralState), animated: true)
            }
        case .expression:
            if inputBar.isExpression {
                sender.status = .down
                inputBar.setInputBarState(.writing(ephemeral: ephemeralState), animated: true)
                self.mode = .textInput
            }
        }
        
        updateIndicateButton()
        updateRightAccessoryView()
    }
}

extension ConversationInputBarViewController {
    
    @objc func markdownButtonPressed(_ sender: IconButton?) {
        configureIndicateButtonStatusToMarkdown()
        inputBar.switchToMarkdown()
    }
}
