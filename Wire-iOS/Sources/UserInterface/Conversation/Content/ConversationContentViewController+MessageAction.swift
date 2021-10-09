
import Foundation
import SDWebImage

extension ConversationContentViewController {
    
    // MARK: - EditMessages
    func editLastMessage() {
        if let lastEditableMessage = conversation.lastEditableMessage {
            perform(action: .edit, for: lastEditableMessage, view: tableView)
        }
    }

    func presentDetails(for message: ZMConversationMessage) {
        let isFile = Message.isFileTransfer(message)
        let isImage = Message.isImage(message)
        let isLocation = Message.isLocation(message)

        guard isFile || isImage || isLocation else { return }

        messagePresenter.open(message, targetView: tableView.targetView(for: message, dataSource: dataSource), actionResponder: self)
    }

    func openSketch(for message: ZMConversationMessage, in editMode: CanvasViewControllerEditMode) {
        let canvasViewController = CanvasViewController()
        if let imageData = message.imageMessageData?.imageData {
            canvasViewController.sketchImage = UIImage(data: imageData)
        }
        canvasViewController.delegate = self
        canvasViewController.title = message.conversation?.displayName.localizedUppercase
        canvasViewController.select(editMode: editMode, animated: false)

        present(canvasViewController.wrapInNavigationController(), animated: true)
    }


    func messageAction(
        actionId: MessageAction,
        for message: ZMConversationMessage,
        view: UIView
    ) {
        switch actionId {
        case .cancel:
            session.enqueueChanges {
                message.fileMessageData?.cancelTransfer()
            }
        case .resend:
            session.enqueueChanges {
                message.resend()
            }
        case .delete:
            assert(message.canBeDeleted)

            deletionDialogPresenter = DeletionDialogPresenter(sourceViewController: presentedViewController ?? self)
            deletionDialogPresenter?.presentDeletionAlertController(forMessage: message, source: view) { deleted in
                if deleted {
                    self.presentedViewController?.dismiss(animated: true)
                }
            }
        case .present:
            dataSource.selectedMessage = message
            presentDetails(for: message)
        case .save:
            if Message.isImage(message) {
                saveImage(from: message, view: view)
            } else {
                dataSource.selectedMessage = message

                let targetView: UIView

                if let selectableView = view as? SelectableView {
                    targetView = selectableView.selectionView
                } else {
                    targetView = view
                }

                if let saveController = UIActivityViewController(message: message, from: targetView) {
                    saveController.completionWithItemsHandler = {(activityType, completed, _, activityError) in
                        if activityType == .saveToCameraRoll,
                            completed, activityError == nil{
                           HUD.success("hud.success.saved".localized)
                        }
                        saveController.completionWithItemsHandler = nil
                    }
                    present(saveController, animated: true)
                }
            }
        case .digitallySign:
            // TODO: ToSwift digitallySign
//            dataSource.selectedMessage = message
//            message.isFileDownloaded()
//                ? signPDFDocument(for: message, observer: self)
//                : presentDownloadNecessaryAlert(for: message)
            break
        case .edit:
            dataSource.editingMessage = message
            delegate?.conversationContentViewController(self, didTriggerEditing: message)
        case .sketchDraw:
            openSketch(for: message, in: .draw)
        case .sketchEmoji:
            openSketch(for: message, in: .emoji)
        case .like, .unlike:
            // The new liked state, the value is flipped
            let updatedLikedState = !Message.isLikedMessage(message)
            guard let indexPath = dataSource.topIndexPath(for: message) else { return }

            let selectedMessage = dataSource.selectedMessage

            session.performChanges {
                Message.setLikedMessage(message, liked: updatedLikedState)
            }

            if updatedLikedState {
                // Deselect if necessary to show list of likers
                if selectedMessage == message {
                    willSelectRow(at: indexPath, tableView: tableView)
                }
            } else {
                // Select if necessary to prevent message from collapsing
                if !(selectedMessage == message) && !Message.hasLikeReactions(message) {
                    willSelectRow(at: indexPath, tableView: tableView)

                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        case .forward:
            showForwardFor(message: message, fromCell: view)
        case .showInConversation:
            scroll(to: message) { cell in
                self.dataSource.highlight(message: message)
            }
        case .copy:
            message.copy(in: .general)
        case .download:
            session.enqueueChanges {
                message.fileMessageData?.requestFileDownload()
            }
        case .reply:
            delegate?.conversationContentViewController(self, didTriggerReplyingTo: message)
        case .openQuote:
            if let quote = message.textMessageData?.quote {
                scroll(to: quote) { cell in
                    self.dataSource.highlight(message: quote)
                }
            }
        case .openDetails:
//            let detailsViewController = MessageDetailsViewController(message: message)
//            parent?.present(detailsViewController, animated: true)
            break
            
        case .illegal:
            showAlert(title: "", message: "conversation.group.message.illegal.alert.describe".localized, okActionHandler: { _ in
                let state = !Message.isIllegalMessage(message)
                self.session.performChanges {
                    Message.setIllegalMessage(message, illegal: state)
                }
            })
        case .addExpressionToFavorite:
            if let url = message.expressionUrl {
                LocalExpressionStore.favorite.addData(url)
                ExpressionModel.shared.postFavoriteExpressionChanged()
            }
            if let data = message.imageMessageData?.imageData {
                let key = data.md5
                SDImageCache.shared.storeImageData(toDisk: data, forKey: key)
                LocalExpressionStore.favorite.addData(key)
                ExpressionModel.shared.postFavoriteExpressionChanged()
            }
        case .translation:
            guard let text = message.textMessageData?.messageText else {
                return
            }
            guard let msg = message as? ZMMessage else {
                return
            }
            TranslationService.translate(text: text) { (result) in
                switch result {
                case .success(let translateText):
                    ZMUserSession.shared()?.enqueueChanges {
                        msg.translationText = translateText
                    }
                case .failure(_):
                    break
                }
            }
            break
        case .showOrigin:
            guard let msg = message as? ZMMessage else {
                return
            }
            ZMUserSession.shared()?.enqueueChanges {
                msg.translationText = nil
            }
        }
        
    }
}
