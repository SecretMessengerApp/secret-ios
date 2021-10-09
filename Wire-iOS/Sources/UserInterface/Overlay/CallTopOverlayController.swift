

import Foundation
import UIKit
import WireDataModel
import avs

protocol CallTopOverlayControllerDelegate: class {
    func voiceChannelTopOverlayWantsToRestoreCall(_ controller: CallTopOverlayController)
}

extension CallState {
    public func description(callee: String, conversation: String, isGroup: Bool) -> String {
        switch self {
        case .incoming(_, _, _):
            let toAppend = (isGroup ? conversation + "・" : "")
            return toAppend + "call.status.incoming.user".localized(args: callee)
        case .outgoing(_):
            return "call.status.outgoing.user".localized(args: conversation)
        case .answered(_), .establishedDataChannel:
            return "call.status.connecting".localized
        case .terminating(_):
            return "call.status.terminating".localized
        default:
            return ""
        }
    }
}

final class CallTopOverlayController: UIViewController {
    private let durationLabel = UILabel()
    
    class TapableAccessibleView: UIView {
        let onAccessibilityActivate: ()->()
        
        init(onAccessibilityActivate: @escaping ()->()) {
            self.onAccessibilityActivate = onAccessibilityActivate
            super.init(frame: .zero)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func accessibilityActivate() -> Bool {
            onAccessibilityActivate()
            return true
        }
    }
    
    private let interactiveView = UIView()
    private let muteIcon = UIImageView()
    private var muteIconWidth: NSLayoutConstraint?
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private weak var callDurationTimer: Timer? = nil
    private var observerToken: Any? = nil
    private let callDurationFormatter = DateComponentsFormatter()
    
    let conversation: ZMConversation
    weak var delegate: CallTopOverlayControllerDelegate? = nil
    
    private var callDuration: TimeInterval = 0 {
        didSet {
            updateLabel()
        }
    }
    
    deinit {
        stopCallDurationTimer()
        AVSMediaManagerClientChangeNotification.remove(self)
    }
    
    init(conversation: ZMConversation) {
        self.conversation = conversation
        callDurationFormatter.allowedUnits = [.minute, .second]
        callDurationFormatter.zeroFormattingBehavior = DateComponentsFormatter.ZeroFormattingBehavior(rawValue: 0)
        super.init(nibName: nil, bundle: nil)
        
        self.observerToken = self.conversation.voiceChannel?.addCallStateObserver(self)
        AVSMediaManagerClientChangeNotification.add(self)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
     
    override func loadView() {
        view = TapableAccessibleView(onAccessibilityActivate: { [weak self] in
            self?.openCall(nil)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openCall(_:)))
        
        view.clipsToBounds = true
        view.backgroundColor = .strongLimeGreen
        view.accessibilityIdentifier = "OpenOngoingCallButton"
        view.shouldGroupAccessibilityChildren = true
        view.isAccessibilityElement = true
        view.accessibilityLabel = "voice.top_overlay.accessibility_title".localized
        view.accessibilityTraits = .button
        
        interactiveView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(interactiveView)
        
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        interactiveView.addSubview(durationLabel)
        durationLabel.font = FontSpec(.small, .semibold).font
        durationLabel.textColor = .white
        durationLabel.lineBreakMode = .byTruncatingMiddle
        durationLabel.textAlignment = .center
        
        muteIcon.translatesAutoresizingMaskIntoConstraints = false
        interactiveView.addSubview(muteIcon)
        muteIconWidth = muteIcon.widthAnchor.constraint(equalToConstant: 0.0)
        displayMuteIcon = false
        
        NSLayoutConstraint.activate([
            interactiveView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            interactiveView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            interactiveView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            interactiveView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.safeArea.top),
            durationLabel.centerYAnchor.constraint(equalTo: interactiveView.centerYAnchor),
            durationLabel.leadingAnchor.constraint(equalTo: muteIcon.trailingAnchor, constant: 8),
            durationLabel.trailingAnchor.constraint(equalTo: interactiveView.trailingAnchor, constant: -16),
            interactiveView.heightAnchor.constraint(equalToConstant: 32),
            muteIcon.leadingAnchor.constraint(equalTo: interactiveView.leadingAnchor, constant: 8),
            muteIcon.centerYAnchor.constraint(equalTo: interactiveView.centerYAnchor),
            muteIconWidth!
            ])
        
        interactiveView.addGestureRecognizer(tapGestureRecognizer)
        updateLabel()
        (conversation.voiceChannel?.state).map(updateCallDurationTimer)
    }
    
    private var displayMuteIcon: Bool = false {
        didSet {
            if displayMuteIcon {
                muteIcon.setIcon(.microphoneWithStrikethrough, size: 12, color: .white)
                muteIconWidth?.constant = 12
            } else {
                muteIcon.image = nil
                muteIconWidth?.constant = 0.0
            }
        }
    }
    
    fileprivate func updateCallDurationTimer(for callState: CallState) {
        switch callState {
        case .established:
            startCallDurationTimer()
        case .terminating:
            stopCallDurationTimer()
        default:
            updateLabel()
            break
        }
    }
    
    private func startCallDurationTimer() {
        stopCallDurationTimer()
        
        callDurationTimer = .scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            [weak self] _ in
            self?.updateCallDuration()
        }
    }
    
    private func updateCallDuration() {
        if let callStartDate = self.conversation.voiceChannel?.callStartDate {
            self.callDuration = -callStartDate.timeIntervalSinceNow
        } else {
            self.callDuration = 0
        }
    }
    
    private func updateLabel() {
        durationLabel.text = statusString.localizedUppercase
        view.accessibilityValue = durationLabel.text
    }
    
    private var statusString: String {
        guard let state = conversation.voiceChannel?.state else {
            return ""
        }
        
        switch state {
        case .established, .establishedDataChannel:
            let duration = callDurationFormatter.string(from: callDuration) ?? ""
            return "voice.top_overlay.tap_to_return".localized + "・" + duration
        default:
            let initiator = self.conversation.voiceChannel?.initiator?.name ?? ""
            let conversation = self.conversation.displayName
            return state.description(callee: initiator, conversation: conversation, isGroup: self.conversation.conversationType == .group)
        }
    }
    
    func stopCallDurationTimer() {
        callDurationTimer?.invalidate()
        callDurationTimer = nil
    }
    
    @objc
    private func openCall(_ sender: UITapGestureRecognizer?) {
        delegate?.voiceChannelTopOverlayWantsToRestoreCall(self)
    }
}

extension CallTopOverlayController: WireCallCenterCallStateObserver {
    func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?) {
        updateCallDurationTimer(for: callState)
    }
}

extension CallTopOverlayController: AVSMediaManagerClientObserver {
    func mediaManagerDidChange(_ notification: AVSMediaManagerClientChangeNotification!) {
        displayMuteIcon = AVSMediaManager.sharedInstance().isMicrophoneMuted
    }
}
