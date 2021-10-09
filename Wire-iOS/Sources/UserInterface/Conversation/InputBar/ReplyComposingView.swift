
import Foundation

protocol ReplyComposingViewDelegate: NSObjectProtocol {
    func composingViewDidCancel(composingView: ReplyComposingView)
    func composingViewWantsToShowMessage(composingView: ReplyComposingView, message: ZMConversationMessage)
}

fileprivate extension ZMConversationMessage {
    var accessibilityDescription: String {
        let contentDescriptionText: String
        let senderDescriptionText = self.sender?.displayName(in: self.conversation) ?? ""
        
        if let textData = textMessageData {
            contentDescriptionText = textData.messageText ?? ""
        }
        else if isImage {
            contentDescriptionText = "conversation.input_bar.message_preview.accessibility.image_message".localized
        }
        else if let locationData = locationMessageData {
            contentDescriptionText = locationData.name ?? "conversation.input_bar.message_preview.accessibility.location_message".localized
        }
        else if isVideo {
            contentDescriptionText = "conversation.input_bar.message_preview.accessibility.video_message".localized
        }
        else if isAudio {
            contentDescriptionText = "conversation.input_bar.message_preview.accessibility.audio_message".localized
        }
        else if let fileData = fileMessageData {
            contentDescriptionText = String(format: "conversation.input_bar.message_preview.accessibility.file_message".localized, fileData.filename ?? "")
        }
        else {
            contentDescriptionText = "conversation.input_bar.message_preview.accessibility.unknown_message".localized
        }
        
        return String(format: "conversation.input_bar.message_preview.accessibility.message_from".localized, contentDescriptionText, senderDescriptionText)
    }
}

final class ReplyComposingView: UIView {
    let message: ZMConversationMessage
    internal let closeButton = IconButton()
    private let leftSideView = UIView(frame: .zero)
    private var messagePreviewContainer: ReplyRoundCornersView!
    private var previewView: UIView!
    weak var delegate: ReplyComposingViewDelegate? = nil
    private var observerToken: Any? = nil
    
    init(message: ZMConversationMessage) {
        require(message.canBeQuoted)
        require(message.conversation != nil)
        
        self.message = message
        super.init(frame: .zero)
        
        setupMessageObserver()
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupMessageObserver() {
        if let userSession = ZMUserSession.shared() {
            observerToken = MessageChangeInfo.add(observer: self, for: message, userSession: userSession)
        }
    }
    
    private func buildAccessibilityLabel() -> String {
        let messageDescription = message.accessibilityDescription
        return String(format: "conversation.input_bar.message_preview.accessibility_description".localized, messageDescription)
    }
    
    private func setupSubviews() {
        backgroundColor = .dynamic(scheme: .background)

        previewView = message.replyPreview()!
        previewView.isUserInteractionEnabled = false
        previewView.isAccessibilityElement = true
        previewView.shouldGroupAccessibilityChildren = true
        previewView.accessibilityIdentifier = "replyView"
        previewView.accessibilityLabel = buildAccessibilityLabel()

        messagePreviewContainer = ReplyRoundCornersView(containedView: previewView)
        messagePreviewContainer.addTarget(self, action: #selector(onTap), for: .touchUpInside)

        leftSideView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        messagePreviewContainer.translatesAutoresizingMaskIntoConstraints = false

        closeButton.isAccessibilityElement = true
        closeButton.accessibilityIdentifier = "cancelReply"
        closeButton.accessibilityLabel = "conversation.input_bar.close_reply".localized
        closeButton.setIcon(.cross, size: .tiny, for: .normal)
        closeButton.setIconColor(.dynamic(scheme: .iconNormal), for: .normal)
        closeButton.addCallback(for: .touchUpInside) { [weak self] _ in
            self?.delegate?.composingViewDidCancel(composingView: self!)
        }
        
        [leftSideView, messagePreviewContainer].forEach(self.addSubview)
        
        leftSideView.addSubview(closeButton)
    }
    
    private func setupConstraints() {
        let margins = directionAwareConversationLayoutMargins
        
        let constraints: [NSLayoutConstraint] = [
//            leftSideView.leadingAnchor.constraint(equalTo: leadingAnchor),
//            leftSideView.topAnchor.constraint(equalTo: topAnchor),
//            leftSideView.bottomAnchor.constraint(equalTo: bottomAnchor),
//            leftSideView.widthAnchor.constraint(equalToConstant: margins.left),
//            closeButton.centerXAnchor.constraint(equalTo: leftSideView.centerXAnchor),
//            closeButton.topAnchor.constraint(equalTo: leftSideView.topAnchor, constant: 16),
//            messagePreviewContainer.topAnchor.constraint(equalTo: topAnchor, constant: 12),
//            messagePreviewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
//            messagePreviewContainer.leadingAnchor.constraint(equalTo: leftSideView.trailingAnchor),
//            messagePreviewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.right),
            messagePreviewContainer.topAnchor.constraint(equalTo: topAnchor),
            messagePreviewContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            messagePreviewContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
//            messagePreviewContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margins.right),
            leftSideView.leadingAnchor.constraint(equalTo: messagePreviewContainer.trailingAnchor),
            leftSideView.topAnchor.constraint(equalTo: topAnchor),
            leftSideView.bottomAnchor.constraint(equalTo: bottomAnchor),
            leftSideView.trailingAnchor.constraint(equalTo: trailingAnchor),
            leftSideView.widthAnchor.constraint(equalToConstant: margins.left),
            
            closeButton.centerXAnchor.constraint(equalTo: leftSideView.centerXAnchor),
            closeButton.centerYAnchor.constraint(equalTo: leftSideView.centerYAnchor),
            
            heightAnchor.constraint(greaterThanOrEqualToConstant: 48)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    @objc func onTap() {
        self.delegate?.composingViewWantsToShowMessage(composingView: self, message: message)
    }

}

extension ReplyComposingView: ZMMessageObserver {
    func messageDidChange(_ changeInfo: MessageChangeInfo) {
        if changeInfo.message.hasBeenDeleted {
            self.delegate?.composingViewDidCancel(composingView: self)
        }
    }
}
