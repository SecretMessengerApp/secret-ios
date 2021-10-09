
import UIKit

protocol CallActionsViewDelegate: class {
    func callActionsView(_ callActionsView: CallActionsView, perform action: CallAction)
}

enum MediaState: Equatable {
    struct SpeakerState: Equatable {
        let isEnabled: Bool
        let canBeToggled: Bool
    }
    case sendingVideo, notSendingVideo(speakerState: SpeakerState)
    
    var isSendingVideo: Bool {
        guard case .sendingVideo = self else { return false }
        return true
    }
    
    var showSpeaker: Bool {
        guard case .notSendingVideo = self else { return false }
        return true
    }
    
    var isSpeakerEnabled: Bool {
        guard case .notSendingVideo(let state) = self else { return false }
        return state.isEnabled
    }
    
    var canSpeakerBeToggled: Bool {
        guard case .notSendingVideo(let state) = self else { return false }
        return state.canBeToggled
    }
}

// This protocol describes the input for a `CallActionsView`.
protocol CallActionsViewInputType: CallTypeProvider, ColorVariantProvider {
    var canToggleMediaType: Bool { get }
    var isMuted: Bool { get }
    var isTerminating: Bool { get }
    var canAccept: Bool { get }
    var mediaState: MediaState { get }
    var permissions: CallPermissionsConfiguration { get }
    var cameraType: CaptureDevice { get }
    var networkQuality: NetworkQuality { get }
}

extension CallActionsViewInputType {
    var appearance: CallActionAppearance {
        switch isVideoCall{
        case true: return .video
        case false: return .audio
        }
    }
}

// A view showing multiple buttons depending on the given `CallActionsView.Input`.
// Button touches result in `CallActionsView.Action` cases to be sent to the objects delegate.
final class CallActionsView: UIView {
    
    weak var delegate: CallActionsViewDelegate?
    
    var isCompact = false {
        didSet {
            lastInput.apply(update)
        }
    }

    private let verticalStackView = UIStackView(axis: .vertical)
    private let topStackView = UIStackView(axis: .horizontal)
    private let bottomStackView = UIStackView(axis: .horizontal)
    
    private var lastInput: CallActionsViewInputType?
    private var videoButtonDisabledTapRecognizer: UITapGestureRecognizer?
    
    // Buttons
    private let muteCallButton = IconLabelButton.muteCall()
    private let videoButton = IconLabelButton.video()
    private let videoButtonDisabled = UIView()
    private let speakerButton = IconLabelButton.speaker()
    private let flipCameraButton = IconLabelButton.flipCamera()
    private let firstBottomRowSpacer = UIView()
    private let endCallButton = IconButton.endCall()
    private let secondBottomRowSpacer = UIView()
    private let acceptCallButton = IconButton.acceptCall()
    
    private var allButtons: [UIButton] {
        return [muteCallButton, videoButton, speakerButton, flipCameraButton, endCallButton, acceptCallButton]
    }
    
    // MARK: - Setup
    
    init() {
        super.init(frame: .zero)
        videoButtonDisabledTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(performButtonAction))
        setupViews()
        setupAccessibility()
        createConstraints()
    }
    
    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        videoButtonDisabled.translatesAutoresizingMaskIntoConstraints = false
        videoButtonDisabled.addGestureRecognizer(videoButtonDisabledTapRecognizer!)
        topStackView.distribution = .equalSpacing
        bottomStackView.distribution = .equalSpacing
        bottomStackView.alignment = .top
        addSubview(verticalStackView)
        [muteCallButton, videoButton, flipCameraButton, speakerButton].forEach(topStackView.addArrangedSubview)
        [firstBottomRowSpacer, endCallButton, secondBottomRowSpacer, acceptCallButton].forEach(bottomStackView.addArrangedSubview)
        [topStackView, bottomStackView].forEach(verticalStackView.addArrangedSubview)
        allButtons.forEach { $0.addTarget(self, action: #selector(performButtonAction), for: .touchUpInside) }
        addSubview(videoButtonDisabled)
    }

    private func setupAccessibility() {
        muteCallButton.accessibilityLabel = "voice.mute_button.title".localized
        videoButton.accessibilityLabel = "voice.video_button.title".localized
        speakerButton.accessibilityLabel = "voice.speaker_button.title".localized
        flipCameraButton.accessibilityLabel = "voice.flip_video_button.title".localized
        acceptCallButton.accessibilityLabel = "voice.accept_button.title".localized
    }
    
    private func createConstraints() {
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: verticalStackView.leadingAnchor),
            topAnchor.constraint(equalTo: verticalStackView.topAnchor),
            trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor),
            bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor),
            firstBottomRowSpacer.widthAnchor.constraint(equalToConstant: IconButton.width),
            firstBottomRowSpacer.heightAnchor.constraint(equalToConstant: IconButton.height),
            secondBottomRowSpacer.widthAnchor.constraint(equalToConstant: IconButton.width),
            secondBottomRowSpacer.heightAnchor.constraint(equalToConstant: IconButton.height),
            videoButtonDisabled.leftAnchor.constraint(equalTo: videoButton.leftAnchor),
            videoButtonDisabled.rightAnchor.constraint(equalTo: videoButton.rightAnchor),
            videoButtonDisabled.topAnchor.constraint(equalTo: videoButton.topAnchor),
            videoButtonDisabled.bottomAnchor.constraint(equalTo: videoButton.bottomAnchor),
        ])
    }
    
    // MARK: - State Input
    
    // Single entry point for all state changes.
    // All side effects should be started from this method.
    func update(with input: CallActionsViewInputType) {
        muteCallButton.isSelected = input.isMuted
        videoButtonDisabled.isUserInteractionEnabled = !input.canToggleMediaType
        videoButtonDisabledTapRecognizer?.isEnabled = !input.canToggleMediaType
        videoButton.isEnabled = input.canToggleMediaType
        videoButton.isSelected = input.mediaState.isSendingVideo && input.permissions.canAcceptVideoCalls
        flipCameraButton.isEnabled = input.mediaState.isSendingVideo && input.permissions.canAcceptVideoCalls
        flipCameraButton.isHidden = input.mediaState.showSpeaker
        speakerButton.isHidden = !input.mediaState.showSpeaker
        speakerButton.isSelected = input.mediaState.isSpeakerEnabled
        speakerButton.isEnabled = input.mediaState.canSpeakerBeToggled
        acceptCallButton.isHidden = !input.canAccept
        firstBottomRowSpacer.isHidden = input.canAccept || isCompact
        secondBottomRowSpacer.isHidden = isCompact
        verticalStackView.axis = isCompact ? .horizontal : .vertical
        [muteCallButton, videoButton, flipCameraButton, speakerButton].forEach { $0.appearance = input.appearance }
        alpha = input.isTerminating ? 0.4 : 1
        isUserInteractionEnabled = !input.isTerminating
        lastInput = input
        updateAccessibilityElements(with: input)
        setNeedsLayout()
        layoutIfNeeded()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        verticalStackView.spacing = {
            guard isCompact else { return 64 } // Calculate the spacing manually in compact mode
            let iconCount = topStackView.visibleSubviews.count + bottomStackView.visibleSubviews.count
            return (bounds.width - (CGFloat(iconCount) * IconButton.width)) / CGFloat(iconCount - 1)
        }()
        topStackView.spacing = isCompact ? verticalStackView.spacing : 32
        bottomStackView.spacing = isCompact ? verticalStackView.spacing : 32
    }
    
    // MARK: - Action Output
    
    @objc private func performButtonAction(_ sender: IconLabelButton) {
        delegate?.callActionsView(self, perform: action(for: sender))
    }
    
    private func action(for button: IconLabelButton) -> CallAction {
        switch button {
        case muteCallButton: return .toggleMuteState
        case videoButton: return .toggleVideoState
        case videoButtonDisabledTapRecognizer: return .alertVideoUnavailable
        case speakerButton: return .toggleSpeakerState
        case flipCameraButton: return .flipCamera
        case endCallButton: return .terminateCall
        case acceptCallButton: return .acceptCall
        default: fatalError("Unexpected Button: \(button)")
        }
    }

    // MARK: - Accessibility

    private func updateAccessibilityElements(with input: CallActionsViewInputType) {
        muteCallButton.accessibilityLabel = "call.actions.label.toggle_mute_\(input.isMuted ? "off" : "on")".localized
        flipCameraButton.accessibilityLabel = "call.actions.label.flip_camera".localized
        speakerButton.accessibilityLabel = "call.actions.label.toggle_speaker_\(input.mediaState.isSpeakerEnabled ? "off" : "on")".localized
        acceptCallButton.accessibilityLabel = "call.actions.label.accept_call".localized
        endCallButton.accessibilityLabel = "call.actions.label.\(input.canAccept ? "reject" : "terminate")_call".localized
        videoButtonDisabled.accessibilityLabel = "call.actions.label.toggle_video_on".localized;
        videoButton.accessibilityLabel = "call.actions.label.toggle_video_\(input.mediaState.isSendingVideo ? "off" : "on")".localized

        let targetCamera = input.cameraType == .front ? "back" : "front"
        flipCameraButton.accessibilityLabel = "call.actions.label.switch_to_\(targetCamera)_camera".localized
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if let input = lastInput {
            update(with: input)
        }
    }

}
