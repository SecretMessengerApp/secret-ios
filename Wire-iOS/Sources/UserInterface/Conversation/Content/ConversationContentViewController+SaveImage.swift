
import Foundation

extension ConversationContentViewController {
    
    func saveImage(from message: ZMConversationMessage, view: UIView?) {
        guard let imageMessageData = message.imageMessageData, let imageData = imageMessageData.imageData else { return }
        
        let savableImage = SavableImage(data: imageData, isGIF: imageMessageData.isAnimatedGIF)
        
        if let view = view {
            let sourceView: UIView

            if let selectableView = view as? SelectableView {
                sourceView = selectableView.selectionView
            } else {
                sourceView = view
            }

            let snapshot = sourceView.snapshotView(afterScreenUpdates: true)
            let sourceRect = sourceView.convert(sourceView.frame, from: sourceView.superview)

            savableImage.saveToLibrary { success in
                guard nil != self.view.window, success else { return }
                snapshot?.translatesAutoresizingMaskIntoConstraints = true
                self.delegate?.conversationContentViewController(self, performImageSaveAnimation: snapshot, sourceRect: sourceRect)
                HUD.success("hud.success.saved".localized)
            }
        } else {
            savableImage.saveToLibrary { success in
                guard nil != self.view.window, success else { return }
                HUD.success("hud.success.saved".localized)
            }
        }
    }
}
