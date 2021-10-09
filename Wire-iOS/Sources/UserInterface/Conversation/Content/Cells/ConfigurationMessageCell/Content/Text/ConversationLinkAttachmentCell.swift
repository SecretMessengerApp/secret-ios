
import UIKit

class ConversationLinkAttachmentCell: UIView, ConversationMessageCell, HighlightableView {

    struct Configuration {
        let attachment: LinkAttachment
        let thumbnailResource: ImageResource?
    }

    let attachmentView = MediaPreviewView()

    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil

    var isSelected: Bool = false
    var currentAttachment: LinkAttachment?
    var heightRatioConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureSubviews() {
        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true
        accessibilityIdentifier = "link-attachment"
        accessibilityTraits = [.link]
        addSubview(attachmentView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        attachmentView.addGestureRecognizer(tapGesture)
    }

    private func configureConstraints() {
        attachmentView.translatesAutoresizingMaskIntoConstraints = false

        let widthConstraint = attachmentView.widthAnchor.constraint(equalToConstant: 414)
        widthConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            attachmentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            attachmentView.topAnchor.constraint(equalTo: topAnchor),
            attachmentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            attachmentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint
        ])
    }

    private func updateAspectRatio(_ heightRatio: CGFloat) {
        if let currentConstraint = self.heightRatioConstraint {
            currentConstraint.isActive = false
        }

        let heightRatioConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: heightRatio)
        heightRatioConstraint.isActive = true
        self.heightRatioConstraint = heightRatioConstraint
    }

    // MARK: - Configuration

    func configure(with object: Configuration, animated: Bool) {
        currentAttachment = object.attachment
        attachmentView.titleLabel.text = object.attachment.title
        attachmentView.previewImageView.setImageResource(object.thumbnailResource, hideLoadingView: true)
        accessibilityValue = object.attachment.title

        switch object.attachment.type {
        case .youTubeVideo:
            updateAspectRatio(3/4)
            attachmentView.providerImageView.image = WireStyleKit.imageOfYoutube(color: .white)
            accessibilityLabel = "content.message.link_attachment.accessibility_label.youtube".localized

        case .soundCloudTrack:
            updateAspectRatio(1/1)
            attachmentView.providerImageView.image = UIImage(named: "soundcloud")
            accessibilityLabel = "content.message.link_attachment.accessibility_label.soundcloud_song".localized

        case .soundCloudPlaylist:
            updateAspectRatio(1/1)
            attachmentView.providerImageView.image = UIImage(named: "soundcloud")
            accessibilityLabel = "content.message.link_attachment.accessibility_label.soundcloud_set".localized
        }
    }

    // MARK: - HighlightableView

    var highlightContainer: UIView {
        return attachmentView
    }

    // MARK: - Events

    @objc private func handleTapGesture() {
        currentAttachment?.permalink.open()
    }

}

class ConversationLinkAttachmentCellDescription: ConversationMessageCellDescription {
    typealias View = ConversationLinkAttachmentCell
    let configuration: View.Configuration

    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 8

    let isFullWidth: Bool = false
    let supportsActions: Bool = true
    let containsHighlightableContent: Bool = true

    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil

    init(attachment: LinkAttachment, thumbnailResource: ImageResource?) {
        configuration = View.Configuration(attachment: attachment, thumbnailResource: thumbnailResource)
        actionController = nil
    }
}
