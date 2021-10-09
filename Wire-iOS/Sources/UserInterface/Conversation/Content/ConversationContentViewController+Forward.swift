
import Foundation
import Cartography

extension ZMConversation: ShareDestination {
    
    var showsGuestIcon: Bool {
        return ZMUser.selfUser().hasTeam &&
            self.conversationType == .oneOnOne &&
            self.activeParticipants.first {
                $0.isGuest(in: self) } != nil
    }
    
    var avatarView: UIView? {
        let avatarView = ConversationAvatarView()
        avatarView.size = .complete
        avatarView.configure(context: .conversation(conversation: self))
        return avatarView
    }
}

extension Array where Element == ZMConversation {

    // Should be called inside ZMUserSession.shared().performChanges block
    func forEachNonEphemeral(_ block: (ZMConversation) -> Void) {
        forEach {
            let timeout = $0.messageDestructionTimeout
            $0.messageDestructionTimeout = nil
            block($0)
            $0.messageDestructionTimeout = timeout
        }
    }
}

func forward(_ message: ZMMessage, to: [AnyObject]) {

    let conversations = to as! [ZMConversation]
    
    if message.isText {
        let fetchLinkPreview = !Settings.disableLinkPreviews
        ZMUserSession.shared()?.performChanges {
            conversations.forEachNonEphemeral {
                // We should not forward any mentions to other conversations
                _ = $0.append(text: message.textMessageData!.messageText!, mentions: [], fetchLinkPreview: fetchLinkPreview)
            }
        }
    }
    else if message.isImage, let imageData = message.imageMessageData?.imageData {
        ZMUserSession.shared()?.performChanges {
            conversations.forEachNonEphemeral { _ = $0.append(imageFromData: imageData) }
        }
    }
    else if message.isVideo || message.isAudio || message.isFile {
        let url  = message.fileMessageData!.fileURL!
        FileMetaDataGenerator.metadataForFileAtURL(url, UTI: url.UTI(), name: url.lastPathComponent) { fileMetadata in
            ZMUserSession.shared()?.performChanges {
                conversations.forEachNonEphemeral { _ = $0.append(file: fileMetadata) }
            }
        }
    }
    else if message.isLocation {
        let locationData = LocationData.locationData(withLatitude: message.locationMessageData!.latitude, longitude: message.locationMessageData!.longitude, name: message.locationMessageData!.name, zoomLevel: message.locationMessageData!.zoomLevel)
        ZMUserSession.shared()?.performChanges {
            conversations.forEachNonEphemeral { _ = $0.append(location: locationData) }
        }
    }
    else {
        fatal("Cannot forward message")
    }
}

extension ZMMessage: Shareable {
    
    func share<ZMConversation>(to: [ZMConversation]) {
        forward(self, to: to as [AnyObject])
    }
    
    typealias I = ZMConversation
}

extension ZMConversationMessage {
    func previewView() -> UIView? {
        let view = preparePreviewView(shouldDisplaySender: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .dynamic(scheme: .background)
        return view
    }
}

extension ZMConversationList {///TODO mv to DM
    func shareableConversations(excluding: ZMConversation? = nil) -> [ZMConversation] {
        return self.map { $0 as! ZMConversation }.filter { (conversation: ZMConversation) -> (Bool) in
            return (
                conversation.conversationType == .oneOnOne ||
                conversation.conversationType == .group ||
                conversation.conversationType == .hugeGroup) &&
                conversation.isSelfAnActiveMember &&
                conversation != excluding
        }
    }
}

// MARK: - popover apperance update

extension ConversationContentViewController {

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.dataSource.calculateSectionsThenReload()
        guard traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass else { return }

        if let keyboardAvoidingViewController = self.presentedViewController as? KeyboardAvoidingViewController,
           let shareViewController = keyboardAvoidingViewController.viewController as? ShareViewController<ZMConversation, ZMMessage> {
            shareViewController.showPreview = traitCollection.horizontalSizeClass != .regular
        }
    }

    func updatePopover() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? PopoverPresenter & UIViewController else { return }
        rootViewController.updatePopoverSourceRect()
    }
}

extension ConversationContentViewController: UIAdaptivePresentationControllerDelegate {

    func showForwardFor(message: ZMConversationMessage?, fromCell: UIView?) {
        guard let message = message else { return }
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? PopoverPresenter & UIViewController else { return }

        endEditing()
        
        let conversations = ZMConversationList.conversations(inUserSession: ZMUserSession.shared()!).shareableConversations(excluding: message.conversation!)

        let shareViewController = ShareViewController<ZMConversation, ZMMessage>(
            shareable: message as! ZMMessage,
            destinations: conversations,
            showPreview: traitCollection.horizontalSizeClass != .regular
        )

        let keyboardAvoiding = KeyboardAvoidingViewController(viewController: shareViewController)
        keyboardAvoiding.disabledWhenInsidePopover = true
        keyboardAvoiding.preferredContentSize = CGSize.IPadPopover.preferredContentSize
        keyboardAvoiding.modalPresentationStyle = .popover
        
        if let popoverPresentationController = keyboardAvoiding.popoverPresentationController {
            if let cell = fromCell as? SelectableView {
                popoverPresentationController.config(from: rootViewController,
                               pointToView: cell.selectionView,
                               sourceView: rootViewController.view)
            }

            popoverPresentationController.backgroundColor = UIColor(white: 0, alpha: 0.5)
            popoverPresentationController.permittedArrowDirections = [.left, .right, .up, .down]
        }
        
        keyboardAvoiding.presentationController?.delegate = self
        
        shareViewController.onDismiss = { (shareController: ShareViewController<ZMConversation, ZMMessage>, _) -> () in
            shareController.presentingViewController?.dismiss(animated: true) {
                UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
            }
        }

        rootViewController.present(keyboardAvoiding, animated: true) {
            UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return traitCollection.horizontalSizeClass == .regular ? .popover : .overFullScreen
    }
}
