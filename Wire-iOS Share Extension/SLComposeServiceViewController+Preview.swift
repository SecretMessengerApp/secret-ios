
import UIKit
import Social
import MobileCoreServices
import WireCommonComponents

/**
 * The description of the preview that can be displayed for an attachment.
 */

enum PreviewItem {
    case image(UIImage)
    case remoteURL(URL)
    case placeholder(StyleKitIcon)
}

extension SLComposeServiceViewController {

    /**
     * Fetches the preview item of the main attachment in the background and provided the result to the UI
     * for displaying it to the user.
     *
     * - parameter completionHandler: The block of code that provided the result of the preview lookup.
     * - parameter item: The preview item for the attachment, if it could be determined.
     * - parameter displayMode: The special mode in which the preview should displayed, if any.
     */

    func fetchMainAttachmentPreview(_ completionHandler: @escaping (_ item: PreviewItem?, _ displayMode: PreviewDisplayMode?) -> Void) {
        func completeTask(_ result: PreviewItem?, _ preferredDisplayMode: PreviewDisplayMode?) {
            DispatchQueue.main.async { completionHandler(result, preferredDisplayMode) }
        }

        DispatchQueue.global(qos: .userInitiated).async {

            guard let attachments = self.appendLinkFromTextIfNeeded(),
                  let (attachmentType, attachment) = attachments.main else {
                completeTask(nil, nil)
                return
            }

            let numberOfAttachments = attachments.values.reduce(0) { $0 + $1.count }
            let defaultDisplayMode: PreviewDisplayMode? = numberOfAttachments > 1 ? .mixed(numberOfAttachments, nil) : nil

            switch attachmentType {
            case .image:
                self.loadSystemPreviewForAttachment(attachment, type: attachmentType) { image, preferredDisplayMode in
                    completeTask(image, defaultDisplayMode.combine(with: preferredDisplayMode))
                }

            case .video:
                self.loadSystemPreviewForAttachment(attachment, type: attachmentType) { image, preferredDisplayMode in
                    completeTask(image, defaultDisplayMode.combine(with: preferredDisplayMode) ?? .video)
                }

            case .rawFile,
                 .fileUrl:
                let fallbackIcon = self.fallbackIcon(forAttachment: attachment, ofType: .rawFile)
                completeTask(.placeholder(fallbackIcon), defaultDisplayMode.combine(with: .placeholder))
            case .url:
                let displayMode = defaultDisplayMode.combine(with: .placeholder)

                attachment.fetchURL {
                    if let url = $0 {
                        guard !url.isFileURL else {
                            completeTask(.placeholder(.document), displayMode)
                            return
                        }
                        completeTask(.remoteURL(url), displayMode)
                    } else {
                        completeTask(.placeholder(.paperclip), displayMode)
                    }
                }
            }
        }
    }
    
    func appendLinkFromTextIfNeeded() -> [AttachmentType: [NSItemProvider]]? {
        
        guard let text = self.contentText,
            var attachments = self.extensionContext?.attachments else {
            return nil
        }
        
        let matches = text.URLsInString
        
        if let match = matches.first,
            let item = NSItemProvider(contentsOf: match),
            attachments.filter(\.hasURL).count == 0 {
            attachments.append(item)
        }
        
        return attachments.sorted
    }

    /**
     * Loads the system preview for the item, if possible.
     */

    private func loadSystemPreviewForAttachment(_ item: NSItemProvider, type: AttachmentType, completionHandler: @escaping (PreviewItem, PreviewDisplayMode?) -> Void) {
        item.loadPreviewImage(options: [NSItemProviderPreferredImageSizeKey: PreviewDisplayMode.pixelSize]) { container, error in
            func useFallbackIcon() {
                let fallbackIcon = self.fallbackIcon(forAttachment: item, ofType: type)
                completionHandler(.placeholder(fallbackIcon), .placeholder)
            }

            guard error == nil else {
                useFallbackIcon()
                return
            }

            if let image = container as? UIImage {
                completionHandler(PreviewItem.image(image), nil)
            } else if let data = container as? Data {
                guard let image = UIImage(data: data) else {
                    useFallbackIcon()
                    return
                }
                completionHandler(PreviewItem.image(image), nil)
            } else {
                useFallbackIcon()
            }
        }
    }

    /// Returns the placeholder icon for the attachment of the specified type.
    private func fallbackIcon(forAttachment item: NSItemProvider, ofType type: AttachmentType) -> StyleKitIcon {
        switch type {
        case .video:
            return .movie
        case .image:
            return .photo
        case .fileUrl:
            return .document
        case .rawFile:
            if item.hasItemConformingToTypeIdentifier(kUTTypeAudio as String) {
                return .microphone
            } else {
                return .document
            }
        case .url:
            return .paperclip
        }
    }

}
