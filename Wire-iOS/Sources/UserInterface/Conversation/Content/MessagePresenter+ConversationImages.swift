
import Foundation

extension MessagePresenter {


    /// return a view controller for viewing image messge
    ///
    /// - Parameters:
    ///   - message: a message with image data
    ///   - actionResponder: a action responder
    ///   - isPreviewing: is peeking with 3D touch?
    /// - Returns: if isPreviewing, return a ConversationImagesViewController otherwise return a the view wrapped in navigation controller
    func imagesViewController(
        for message: ZMConversationMessage,
        actionResponder: MessageActionResponder,
        isPreviewing: Bool
    ) -> UIViewController {
        
        guard let conversation = message.conversation else {
            fatal("Message has no conversation.")
        }

        guard let imageSize = message.imageMessageData?.originalSize else {
            fatal("Image in message has no size.")
        }

        let imagesCategoryMatch = CategoryMatch(including: .image, excluding: .none)
        
        let collection = AssetCollectionWrapper(conversation: conversation, matchingCategories: [imagesCategoryMatch])
        
        let imagesController = ConversationImagesViewController(collection: collection, initialMessage: message, inverse: true)
        imagesController.isPreviewing = isPreviewing

        // preferredContentSize should not excess view's size
        if isPreviewing {
            let ratio = UIScreen.main.bounds.size.minZoom(imageSize: imageSize)
            let preferredContentSize = CGSize(width: imageSize.width * ratio, height: imageSize.height * ratio)

            imagesController.preferredContentSize = preferredContentSize
        }

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            imagesController.modalPresentationStyle = .fullScreen;
            imagesController.snapshotBackgroundView = UIScreen.main.snapshotView(afterScreenUpdates: true)
        } else {
            imagesController.modalPresentationStyle = .overFullScreen
        }
        imagesController.modalTransitionStyle = .crossDissolve

        

        let closeButton = CollectionsView.closeButton()
        closeButton.addTarget(self, action: #selector(MessagePresenter.closeImagesButtonPressed(_:)), for: .touchUpInside)
        
        imagesController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        imagesController.messageActionDelegate = actionResponder
        imagesController.swipeToDismiss = true
        imagesController.dismissAction = { [weak self] completion in
            guard let `self` = self else {
                return
            }
            self.modalTargetController?.dismiss(animated: true, completion: completion)
        }

        if isPreviewing {
            return imagesController
        } else {
            return imagesController.wrapInNavigationController(navigationBarClass: UINavigationBar.self)
        }
    }
    
    @objc func closeImagesButtonPressed(_ sender: AnyObject!) {
        modalTargetController?.dismiss(animated: true, completion: .none)
    }
}
