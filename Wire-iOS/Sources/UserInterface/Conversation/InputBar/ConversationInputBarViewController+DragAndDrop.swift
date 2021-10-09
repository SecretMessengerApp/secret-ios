
import Foundation
import WireSystem
import UIKit

private let zmLog = ZMSLog(tag: "Drag and drop images")

extension ConversationInputBarViewController: UIDropInteractionDelegate {

    @available(iOS 11.0, *)
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {

        for dragItem in session.items {
            dragItem.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { object, error in

                guard error == nil else { return zmLog.error("Failed to load dragged item: \(error!.localizedDescription)") }
                guard let draggedImage = object as? UIImage else { return }

                DispatchQueue.main.async {
                    let context = ConfirmAssetViewController.Context(
                        isHugeGroupConversation: self.conversation.conversationType == .hugeGroup,
                        asset: .image(mediaAsset: draggedImage),
                        onConfirm: { [unowned self] (editedImage, isOriginal) in
                            self.dismiss(animated: true) {
                                if let draggedImageData = draggedImage.pngData() {
                                    self.sendController.sendMessage(
                                        withImageData: draggedImageData,
                                        isOriginal: isOriginal
                                    )
                                }
                            }
                        },
                        onCancel: { [unowned self] in
                            self.dismiss(animated: true)
                        }
                    )

                    let confirmImageViewController = ConfirmAssetViewController(context: context)
                    confirmImageViewController.previewTitle = self.conversation.displayName.localizedUppercase
                    self.present(confirmImageViewController, animated: true)
                }
            })
            ///TODO: it's a temporary solution to drag only one image, while we have no design for multiple images
            break
        }
    }

    @available(iOS 11.0, *)
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }

    @available(iOS 11.0, *)
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self)
    }
}
