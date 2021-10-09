//
//  ConversationListViewController+Popover.swift
//  Wire-iOS

import UIKit

extension ConversationListViewController: UIPopoverPresentationControllerDelegate {
    
    func presentPopoverController(source: UIView) {
        let vc = ConversationListPopoverController()
        vc.didSelectCell = { [weak self] type in
            switch type {
            case .group:
                self?.presentedViewController?.dismiss(animated: false) {
                    let controller = ConversationCreationController()
                    controller.delegate = self
                    let avoiding = KeyboardAvoidingViewController(viewController: controller).wrapInNavigationController()
                    self?.presentPossible(avoiding)
                }
            case .add:
                self?.presentedViewController?.dismiss(animated: false) {
                    let controller = AddFriendViewController()
                    controller.delegate = self
                    let avoiding = KeyboardAvoidingViewController(viewController: controller).wrapInNavigationController()
                    self?.presentPossible(avoiding)
                }
            case .scan:
                self?.presentedViewController?.dismiss(animated: false) {
                    let vc = ScanForConversationListViewController().wrapInNavigationController()
                    self?.pushRightPossible(vc)
                    self?.presentFullscreenPossible(vc)
                }
            }
        }
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView = source
        let origin: CGPoint =  UIScreen.isPhone ? .zero : CGPoint(x: -145 / 2, y: 0)
        vc.popoverPresentationController?.sourceRect = CGRect(origin: origin, size: source.frame.size)
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.popoverBackgroundViewClass = ConversationListPopoverBackgroundView.self
        present(vc, animated: true, completion: nil)
    }
    
    private func presentPossible(_ vc: UIViewController) {
        if UIScreen.isPad {
            self.present(vc, animated: true, completion: nil)
        } else {
            self.push(vc)
        }
    }
    
    private func pushRightPossible(_ vc: UIViewController) {
        if UIScreen.isPad {
            self.wr_splitViewController?.setRightViewController(vc, animated: true)
        } else {
            self.push(vc)
        }
    }
    
    func presentFullscreenPossible(_ vc: UIViewController) {
        if UIScreen.isPad {
            vc.modalPresentationStyle = .fullScreen //or .overFullScreen for transparency
            self.present(vc, animated: true, completion: nil)
        } else {
            self.push(vc)
        }
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func push(_ viewController: UIViewController) {
        wr_splitViewController?.setLeftViewControllerRevealed(false, animated: true, completion: nil)
        wr_splitViewController?.setRightViewController(viewController, animated: false)
    }
}


// MARK: - ConversationCreationControllerDelegate
extension ConversationListViewController: ConversationCreationControllerDelegate {
    
    func conversationCreationController(
        _ controller: ConversationCreationController,
        didSelectName name: String,
        participants: Set<ZMUser>,
        allowGuests: Bool
    ) {
        guard let session = ZMUserSession.shared() else { return }
        controller.navigationController?.popToRootViewController(animated: false)
        session.enqueueChanges {
            let conversation = ZMConversation.insertGroupConversation(
                into: session.managedObjectContext,
                withParticipants: Array(participants),
                name: name,
                in: nil,
                allowGuests: allowGuests
            )
            guard let conv = conversation else {return}
            let token = ConversationChangeInfo.add(observer: self, for: conv)
            self.createConversationObservers.append(token)
        }
    }
    
    func conversationCreationControllerWantToDismissByTapX(_ controller: ConversationCreationController) {
        if UIScreen.isPad {
            return
        }
        let revealed = wr_splitViewController?.isLeftViewControllerRevealed ?? false
        wr_splitViewController?.setLeftViewControllerRevealed(!revealed, animated: true, completion: nil)
    }
}

extension ConversationListViewController: ZMConversationObserver {
    func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
        if changeInfo.remoteIdentifierChanged {
            ZClientViewController.shared?.select(conversation: changeInfo.conversation, focusOnView: true, animated: true)
            self.createConversationObservers.removeAll()
        }
    }
}


// MARK: - AddFriendViewControllerDelegate
extension ConversationListViewController: AddFriendViewControllerDelegate {
    
    func addFriendViewControllerWantToDismissByTapX(_ controller: AddFriendViewController) {
        if UIScreen.isPad {
            return
        }
        
        let revealed = wr_splitViewController?.isLeftViewControllerRevealed ?? false
        wr_splitViewController?.setLeftViewControllerRevealed(!revealed, animated: true, completion: nil)
    }
}
