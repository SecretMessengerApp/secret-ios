
import Foundation

extension ConversationInputBarViewController {
    
    func setupViews() {
        updateEphemeralIndicatorButtonTitle(ephemeralIndicatorButton)

        setupInputBar()
        
        createDisableSendMsgLabel()
        
        [audioButton, sendButton, ephemeralIndicatorButton, hourglassButton]
            .forEach(inputBar.rightAccessoryStackView.addArrangedSubview)
        inputBar.leftAccessoryView.addSubview(indicateButton)
        inputBar.addSubview(typingIndicatorView)
        
        createConstraints()
    }
    

    var inputBarButtons: [IconButton] {
        var buttons = [
            photoButton,
            videoButton,
            mentionButton,
            expressionButton,
            assistantBotButton,
            sketchButton,
            markdownButton,
//            gifButton,
            pingButton,
            uploadFileButton,
            locationButton,
        ]
        buttons.forEach { $0.hitAreaPadding = .zero }
        
        let removed = { (_ shouldRemoved: [IconButton]) in
            buttons = buttons.filter { !shouldRemoved.contains($0) }
        }
        
        switch conversation.conversationType {
        case .group:
            removed([assistantBotButton])
        case .hugeGroup:
            removed([pingButton, mentionButton])
            if conversation.assistantBot?.isEmpty ?? true {
                removed([assistantBotButton])
            }
        case .self, .oneOnOne, .connection :
            removed([mentionButton, assistantBotButton])
        default:
            break
        }
        return buttons
    }

    
    private func setupInputBar() {
        audioButton.accessibilityIdentifier = "audioButton"
        videoButton.accessibilityIdentifier = "videoButton"
        photoButton.accessibilityIdentifier = "photoButton"
        uploadFileButton.accessibilityIdentifier = "uploadFileButton"
        sketchButton.accessibilityIdentifier = "sketchButton"
        pingButton.accessibilityIdentifier = "pingButton"
        locationButton.accessibilityIdentifier = "locationButton"
        gifButton.accessibilityIdentifier = "gifButton"
        mentionButton.accessibilityIdentifier = "mentionButton"
        indicateButton.accessibilityIdentifier = "indicateButton"

        markdownButton.accessibilityIdentifier = "markdownButton"
        expressionButton.accessibilityIdentifier = "expressionButton"
        assistantBotButton.accessibilityIdentifier = "assistantBotButton"
        
        inputBar.textView.delegate = self
        inputBar.textView.informalTextViewDelegate = self
        registerForTextFieldSelectionChange()

        view.addSubview(inputBar)

        inputBar.editingView.delegate = self
    }
    
    private func createConstraints() {
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        indicateButton.translatesAutoresizingMaskIntoConstraints = false
        hourglassButton.translatesAutoresizingMaskIntoConstraints = false
        typingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        disableSendMsgLabel.translatesAutoresizingMaskIntoConstraints = false

        let bottomConstraint = inputBar.bottomAnchor.constraint(equalTo: inputBar.superview!.bottomAnchor)
//        bottomConstraint.priority = .defaultLow

        let senderDiameter: CGFloat = 28

        NSLayoutConstraint.activate([
            inputBar.topAnchor.constraint(equalTo: inputBar.superview!.topAnchor),
            inputBar.leadingAnchor.constraint(equalTo: inputBar.superview!.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: inputBar.superview!.trailingAnchor),
            bottomConstraint,

            sendButton.widthAnchor.constraint(equalToConstant: InputBar.rightIconSize),
            sendButton.heightAnchor.constraint(equalToConstant: InputBar.rightIconSize),
            
            audioButton.widthAnchor.constraint(equalToConstant: InputBar.rightIconSize),
            audioButton.heightAnchor.constraint(equalToConstant: InputBar.rightIconSize),

            ephemeralIndicatorButton.widthAnchor.constraint(equalToConstant: InputBar.rightIconSize),
            ephemeralIndicatorButton.heightAnchor.constraint(equalToConstant: InputBar.rightIconSize),

            indicateButton.centerXAnchor.constraint(equalTo: indicateButton.superview!.centerXAnchor),
             indicateButton.centerYAnchor.constraint(equalTo: indicateButton.superview!.centerYAnchor),
//            indicateButton.bottomAnchor.constraint(equalTo: indicateButton.superview!.bottomAnchor, constant: -14),
            indicateButton.widthAnchor.constraint(equalToConstant: senderDiameter),
            indicateButton.heightAnchor.constraint(equalToConstant: senderDiameter),

            hourglassButton.widthAnchor.constraint(equalToConstant: InputBar.rightIconSize),
            hourglassButton.heightAnchor.constraint(equalToConstant: InputBar.rightIconSize),

            typingIndicatorView.centerYAnchor.constraint(equalTo: inputBar.topAnchor),
            typingIndicatorView.centerXAnchor.constraint(equalTo: typingIndicatorView.superview!.centerXAnchor),
            typingIndicatorView.leftAnchor.constraint(greaterThanOrEqualTo: typingIndicatorView.superview!.leftAnchor, constant: 48),
            typingIndicatorView.rightAnchor.constraint(lessThanOrEqualTo: typingIndicatorView.superview!.rightAnchor, constant: 48)
            ]
        )
        
        disableSendMsgLabel.secret.pin()
    }
}
