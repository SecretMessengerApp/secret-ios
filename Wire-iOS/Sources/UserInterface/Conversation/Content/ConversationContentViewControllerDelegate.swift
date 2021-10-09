
import Foundation
import WireDataModel
import UIKit

protocol ConversationContentViewControllerDelegate: class {

    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        willDisplayActiveMediaPlayerFor message: ZMConversationMessage?
    )

    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didEndDisplayingActiveMediaPlayerFor message: ZMConversationMessage
    )

    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didTriggerResending message: ZMConversationMessage
    )

    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didTriggerEditing message: ZMConversationMessage
    )

    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        didTriggerReplyingTo message: ZMConversationMessage
    )

    func conversationContentViewController(
        _ contentViewController: ConversationContentViewController,
        performImageSaveAnimation snapshotView: UIView?,
        sourceRect: CGRect
    )

    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        shouldBecomeFirstResponderWhenShowMenuFromCell cell: UIView
    ) -> Bool

    func conversationContentViewControllerWants(
        toDismiss controller: ConversationContentViewController
    )

    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        presentGuestOptionsFrom sourceView: UIView
    )

    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        presentParticipantsDetailsWithSelectedUsers selectedUsers: [UserType],
        from sourceView: UIView
    )

    func didTap(onUserAvatar user: UserType, view: UIView, frame: CGRect)
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        wantsToShowConversation cid: String,
        appID: String, appName: String, appIcon: String,
        content: String
    )
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        presentRejectAppNoticeActionSheetWithAppID appID: String
    )
    
   
    func aiStartTyping()

    func aiEndTyping()
    

    func conversationContentWillBeginDecelerating()
    func conversationContentWillEndDecelerating()
    
    func conversationContentViewController(
        _ controller: ConversationContentViewController,
        wantsToOpenURL url: URL
    )
    
    func conversationContentViewController(wantToMention user: UserType)
}
