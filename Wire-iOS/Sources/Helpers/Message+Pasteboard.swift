
import Foundation
import FLAnimatedImage
import UIKit
import WireDataModel

extension ZMConversationMessage {

    func copy(in pasteboard: UIPasteboard) {
        if self.isText {
            if let text = textMessageData?.messageText, !text.isEmpty {
                pasteboard.string = text
            }
        } else if isImage,
                  let imageData = imageMessageData?.imageData {

            let mediaAsset: MediaAsset?
            if imageMessageData?.isAnimatedGIF == true {
                mediaAsset = FLAnimatedImage(animatedGIFData: imageData)
            } else {
                mediaAsset = UIImage(data: imageData)
            }

            UIPasteboard.general.setMediaAsset(mediaAsset)
        } else if self.isLocation {
            if let locationName = locationMessageData?.name {
                pasteboard.string = locationName
            }
        }
    }

}
