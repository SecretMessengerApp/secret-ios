

import Foundation
import UIKit
import WireSystem
import WireDataModel

private let zmLog = ZMSLog(tag: "ConversationViewController+ConversationContentViewControllerDelegate")

extension ConversationViewController: ConversationContentViewControllerDelegate {
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        wantsToShowConversation cid: String,
        appID: String, appName: String, appIcon: String,
        content: String
    ) {
        guard
            let cid = UUID(uuidString: cid),
            let conversation = ZMConversation(remoteID: cid)
            else { return }
        zClientViewController.select(conversation: conversation)
    }
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        presentRejectAppNoticeActionSheetWithAppID appID: String
    ) {
        let controller = UIAlertController(
            title: nil,
            message: "Reject the applet message and the app will not be able to send such notifications",
            preferredStyle: .actionSheet
        )
        let reject = UIAlertAction(title: "Reject the applet message", style: .destructive) { _ in
            self.rejectAppNotice(appID: appID) { _ in
                controller.dismissIfNeeded()
            }
        }
        [.cancel(), reject].forEach(controller.addAction)
        present(controller, animated: true)
    }
    
    func aiStartTyping() {
        inputBarController.aiStartTyping()
    }
    
    func aiEndTyping() {
        inputBarController.aiEndTyping()
    }
    
    func conversationContentWillBeginDecelerating() {
        navigantionBarShouldHide(true)
    }
    
    func conversationContentWillEndDecelerating() {
        navigantionBarShouldHide(false)
    }
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        wantsToOpenURL url: URL
    ) {
        let controller = BrowserViewController(url: url)
        present(controller, animated: true)
    }
    
    func conversationContentViewController(wantToMention user: UserType) {
        inputBarController.insertMentionDirect(for: user)
    }
    
    func didTap(onUserAvatar user: UserType, view: UIView, frame: CGRect) {
        guard
            let user = user as? ZMUser,
            user.remoteIdentifier.transportString() != conversation.assistantBot
            else { return }
        guard
            let selfUser = ZMUser.selfUser(),
            conversation.isAllowMemberAddEachOther ||
            conversation.creator.isSelfUser ||
            conversation.manager?.contains(selfUser.remoteIdentifier.transportString()) == true
            else { return }
        
        let profileViewController = UserProfileViewController(
            user: user,
            connectionConversation: user.connection?.conversation,
            userProfileViewControllerDelegate: self,
            groupConversation: conversation,
            isCreater: conversation.creator.isSelfUser
        )
        profileViewController.preferredContentSize = CGSize.IPadPopover.preferredContentSize
        
        endEditing()

        createAndPresentParticipantsPopoverController(
            with: frame,
            from: view,
            contentViewController: profileViewController.wrapInNavigationController()
        )
    }
    
    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        willDisplayActiveMediaPlayerFor message: ZMConversationMessage?
    ) {
        conversationBarController.dismiss(bar: mediaBarViewController)
    }
    
    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didEndDisplayingActiveMediaPlayerFor message: ZMConversationMessage
    ) {
        conversationBarController.present(bar: mediaBarViewController)
    }
    
    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didTriggerResending message: ZMConversationMessage
    ) {
        ZMUserSession.shared()?.enqueueChanges {
            message.resend()
        }
    }
    
    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didTriggerEditing message: ZMConversationMessage
    ) {
        guard let _ = message.textMessageData?.messageText else { return }
        inputBarController.editMessage(message)
    }
    
    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didTriggerReplyingTo message: ZMConversationMessage
    ) {
        let replyComposingView = contentViewController.createReplyComposingView(for: message)
        inputBarController.reply(to: message, composingView: replyComposingView)
    }
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        shouldBecomeFirstResponderWhenShowMenuFromCell cell: UIView
    ) -> Bool {
        if inputBarController.inputBar.textView.isFirstResponder {
            inputBarController.inputBar.textView.overrideNextResponder = cell
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(menuDidHide(_:)),
                name: UIMenuController.didHideMenuNotification,
                object: nil
            )
            return false
        }
        return true
    }
    
    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        performImageSaveAnimation snapshotView: UIView?,
        sourceRect: CGRect
    ) {
        if let snapshotView = snapshotView {
            view.addSubview(snapshotView)
        }
        snapshotView?.frame = view.convert(sourceRect, from: contentViewController.view)
        
        let targetView = inputBarController.photoButton
        let targetCenter = view.convert(targetView.center, from: targetView.superview)
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseIn, animations: {
            snapshotView?.center = targetCenter
            snapshotView?.alpha = 0
            snapshotView?.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }) { finished in
            snapshotView?.removeFromSuperview()
            self.inputBarController.bounceCameraIcon()
        }
    }
    
    func conversationContentViewControllerWants(
        toDismiss controller: ConversationContentViewController
    ) {
        openConversationList()
    }
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        presentGuestOptionsFrom sourceView: UIView
    ) {
        guard ![.group, .hugeGroup].contains(conversation.conversationType) else {
            zmLog.error("Illegal Operation: Trying to show guest options for non-group conversation")
            return
        }
        
        let groupDetailsViewController = GroupDetailsViewController(conversation: conversation)
        let navigationController = groupDetailsViewController.wrapInNavigationController()
        groupDetailsViewController.presentGuestOptions(animated: false)
        presentParticipantsViewController(navigationController, from: sourceView)
    }
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        presentParticipantsDetailsWithSelectedUsers selectedUsers: [UserType],
        from sourceView: UIView
    ) {
        if let groupDetailsViewController = (participantsController as? UINavigationController)?.topViewController as? GroupDetailsViewController {
                groupDetailsViewController.presentParticipantsDetails(
                    with: conversation.sortedOtherParticipants,
                    selectedUsers: selectedUsers,
                    animated: false
            )
        }
        
        if let participantsController = participantsController {
            presentParticipantsViewController(participantsController, from: sourceView)
        }
    }
}

extension ConversationViewController {
    
    func presentParticipantsViewController(
        _ viewController: UIViewController,
        from sourceView: UIView
    ) {
        ConversationInputBarViewController.endEditingMessage()
        inputBarController.inputBar.textView.resignFirstResponder()
        
        createAndPresentParticipantsPopoverController(
            with: sourceView.bounds,
            from: sourceView,
            contentViewController: viewController
        )
    }
    
    //MARK: - Application Events & Notifications

    @objc
    func menuDidHide(_ notification: Notification?) {
        inputBarController.inputBar.textView.overrideNextResponder = nil
        NotificationCenter.default.removeObserver(self, name: UIMenuController.didHideMenuNotification, object: nil)
    }
}
