

import Foundation
import WireShareEngine
import MobileCoreServices

/// `UnsentSendable` implementation to send GIF image messages
final class UnsentGifImageSendable: UnsentSendableBase, UnsentSendable {
    private var gifImageData: Data?
    private let attachment: NSItemProvider
    
    init?(conversation: Conversation, sharingSession: SharingSession, attachment: NSItemProvider) {
        guard attachment.hasItemConformingToTypeIdentifier(kUTTypeGIF as String) else { return nil }
        self.attachment = attachment
        super.init(conversation: conversation, sharingSession: sharingSession)
        needsPreparation = true
    }
    
    func prepare(completion: @escaping () -> Void) {
        precondition(needsPreparation, "Ensure this objects needs preparation, c.f. `needsPreparation`")
        needsPreparation = false
        
        attachment.loadItem(forTypeIdentifier: kUTTypeGIF as String) { [weak self] (url, error) in
            
            error?.log(message: "Unable to load image from attachment")
            
            if let url = url as? URL,
               let data = try? Data(contentsOf: url) {
                self?.gifImageData = data
            } else if let data = url as? Data {
                self?.gifImageData = data
            } else {
                error?.log(message: "Invalid Gif data")
            }
            
            completion()
        }
    }
    
    func send(completion: @escaping (Sendable?) -> Void) {
        sharingSession.enqueue { [weak self] in
            guard let `self` = self else { return }
            completion(self.gifImageData.flatMap(self.conversation.appendImage))
        }
    }
}
