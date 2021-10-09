
import Foundation
import UIKit

extension ConversationViewController {
    
    func updateOutgoingConnectionVisibility() {
        let outgoingConnection: Bool = conversation.relatedConnectionState == .sent
        contentViewController.tableView.isScrollEnabled = !outgoingConnection

        if outgoingConnection {
            if outgoingConnectionViewController != nil {
                return
            }
            
            createOutgoingConnectionViewController()
            
            if let outgoingConnectionViewController = outgoingConnectionViewController {
                outgoingConnectionViewController.willMove(toParent: self)
                view.addSubview(outgoingConnectionViewController.view)
                addChild(outgoingConnectionViewController)
                outgoingConnectionViewController.view.fitInSuperview(exclude: [.top])
            }
        } else {
            outgoingConnectionViewController?.willMove(toParent: nil)
            outgoingConnectionViewController?.view.removeFromSuperview()
            outgoingConnectionViewController?.removeFromParent()
            self.outgoingConnectionViewController = nil
        }
    }

    func createConstraints() {
        [conversationBarController.view,
         contentViewController.view,
         inputBarController.view].forEach(){$0?.translatesAutoresizingMaskIntoConstraints = false}

        NSLayoutConstraint.activate([
            conversationBarController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            conversationBarController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            conversationBarController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        
            contentViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
            inputBarController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            inputBarController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
        
        contentViewController.view.bottomAnchor.constraint(equalTo: inputBarController.view.topAnchor).isActive = true
        
        inputBarBottomMargin = inputBarController.view.bottomAnchor.constraint(equalTo: view.safeBottomAnchor)
        inputBarBottomMargin?.isActive = true

        inputBarZeroHeight = inputBarController.view.heightAnchor.constraint(equalToConstant: 0)
    }

    @objc
    func keyboardFrameWillChange(_ notification: Notification) {
        // We only respond to keyboard will change frame if the first responder is not the input bar
        if invisibleInputAccessoryView.window == nil {
            UIView.animate(withKeyboardNotification: notification, in: view, animations: { [weak self] keyboardFrameInView in
                guard let weakSelf = self else { return }
                weakSelf.inputBarBottomMargin?.constant = -keyboardFrameInView.size.height
            })
        } else {
            if let screenRect: CGRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
                let currentFirstResponder = UIResponder.currentFirst,
                let height = currentFirstResponder.inputAccessoryView?.bounds.size.height {

                let keyboardSize = CGSize(width: screenRect.size.width, height: height)
                UIView.setLastKeyboardSize(keyboardSize)
            }
        }
    }
}
