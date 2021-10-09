
import WireShareEngine
import MobileCoreServices
import WireDataModel

enum AttachmentType:Int, CaseIterable {
    static func < (lhs: AttachmentType, rhs: AttachmentType) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case video = 2
    case image
    case rawFile
    case url
    case fileUrl
}

final class ExtensionActivity {

    static private var openedEventName = "share_extension_opened"
    static private var sentEventName = "share_extension_sent"
    static private var cancelledEventName = "share_extension_cancelled"

    private var verifiedConversation = false
    private var conversationDidDegrade = false

    private var numberOfImages: Int {
        return attachments[.image]?.count ?? 0
    }

    private var hasVideo: Bool {
        return attachments.keys.contains(.video)
    }

    private var hasFile: Bool {
        return attachments.keys.contains(.rawFile)
    }

    public var hasText = false

    let attachments: [AttachmentType: [NSItemProvider]]

    public var conversation: Conversation? = nil {
        didSet {
            verifiedConversation = conversation?.securityLevel == .secure
        }
    }

    init(attachments: [AttachmentType: [NSItemProvider]]?) {
        self.attachments = attachments ?? [:]
    }

    func markConversationDidDegrade() {
        conversationDidDegrade = true
    }

    func openedEvent() -> StorableTrackingEvent {
        return StorableTrackingEvent(
            name: ExtensionActivity.openedEventName,
            attributes: [:]
        )
    }

    func cancelledEvent() -> StorableTrackingEvent {
        return StorableTrackingEvent(
            name: ExtensionActivity.cancelledEventName,
            attributes: [:]
        )
    }

    func sentEvent(completion: @escaping (StorableTrackingEvent) -> Void) {
        let event = StorableTrackingEvent(
            name: ExtensionActivity.sentEventName,
            attributes: [
                "verified_conversation": self.verifiedConversation,
                "number_of_images": self.numberOfImages,
                "video": self.hasVideo,
                "file": self.hasFile,
                "text": self.hasText,
                "conversation_did_degrade": self.conversationDidDegrade
            ]
        )

        completion(event)
    }

}

extension NSItemProvider {
    var hasGifImage: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeGIF as String)
    }

    var hasImage: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeImage as String)
    }

    func hasFile(completion: @escaping (Bool) -> Void) {
        guard !hasImage && !hasVideo else { return completion(false) }
        if hasURL {
            fetchURL { [weak self] url in
                if (url != nil && !url!.isFileURL) || self?.hasData == false {
                    return completion(false)
                }
                completion(true)
            }
        } else {
            completion(hasData)
        }
    }

    private var hasData: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeData as String)
    }

    var hasURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeURL as String) && registeredTypeIdentifiers.count == 1
    }

    var hasFileURL: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeFileURL as String)
    }

    var hasVideo: Bool {
        guard let uti = registeredTypeIdentifiers.first else { return false }
        return UTTypeConformsTo(uti as CFString, kUTTypeMovie)
    }

    var hasRawFile: Bool {
        return hasItemConformingToTypeIdentifier(kUTTypeContent as String) && !hasItemConformingToTypeIdentifier(kUTTypePlainText as String)
    }
}
