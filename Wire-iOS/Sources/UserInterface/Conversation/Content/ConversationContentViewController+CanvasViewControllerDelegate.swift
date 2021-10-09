
import Foundation

extension ConversationContentViewController: CanvasViewControllerDelegate {
    
    func canvasViewController(_ canvasViewController: CanvasViewController, didExportImage image: UIImage, isOriginal: Bool) {
        parent?.dismiss(animated: true) {
            if let imageData = image.pngData() {
                
                ZMUserSession.shared()?.enqueueChanges({
                    self.conversation.append(imageFromData: imageData, isOriginal: isOriginal)
                }, completionHandler: {
                    Analytics.shared().tagMediaActionCompleted(.photo, inConversation: self.conversation)
                })
            }
        }
    }
}

