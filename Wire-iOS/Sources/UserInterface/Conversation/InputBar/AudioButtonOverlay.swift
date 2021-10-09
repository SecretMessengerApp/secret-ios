


import Foundation
import Cartography

final class AudioButtonOverlay: UIView {
    
    enum AudioButtonOverlayButtonType {
        case play, send, stop
    }
    
    typealias ButtonPressHandler = (AudioButtonOverlayButtonType) -> Void
    
    var recordingState: AudioRecordState = .recording {
        didSet { updateWithRecordingState(recordingState) }
    }
    
    var playingState: PlayingState = .idle {
        didSet { updateWithPlayingState(playingState) }
    } 
    
    fileprivate var aHeightConstraint: NSLayoutConstraint?
    fileprivate var aWidthConstraint: NSLayoutConstraint?
        
    let audioButton = IconButton()
    let playButton = IconButton()
    let sendButton = IconButton()
    let backgroundView = UIView()
    var buttonHandler: ButtonPressHandler?
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
        createConstraints()
        updateWithRecordingState(recordingState)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.layer.cornerRadius = bounds.width / 2
    }

    func configureViews() {
        translatesAutoresizingMaskIntoConstraints = false
        audioButton.isUserInteractionEnabled = false
        audioButton.setIcon(.microphone, size: .tiny, for: [])
        audioButton.accessibilityIdentifier = "audioRecorderRecord"
        
        playButton.setIcon(.play, size: .tiny, for: [])
        playButton.accessibilityIdentifier = "audioRecorderPlay"
        playButton.accessibilityValue = PlayingState.idle.description

        sendButton.setIcon(.checkmark, size: .tiny, for: [])
        sendButton.accessibilityIdentifier = "audioRecorderSend"
        
        [backgroundView, audioButton, sendButton, playButton].forEach(addSubview)
        backgroundView.backgroundColor = .dynamic(scheme: .secondaryBackground)
        
        playButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    func createConstraints() {
        let initialViewWidth: CGFloat = 40
        
        constrain(self, audioButton, playButton, sendButton, backgroundView) { view, audioButton, playButton, sendButton, backgroundView in
            audioButton.centerY == view.bottom - initialViewWidth / 2
            audioButton.centerX == view.centerX
            
            playButton.centerX == view.centerX
            playButton.centerY == view.bottom - initialViewWidth / 2
            
            sendButton.centerX == view.centerX
            sendButton.centerY == view.top + initialViewWidth / 2
            
            aWidthConstraint = view.width == initialViewWidth
            aHeightConstraint = view.height == 96
            backgroundView.edges == view.edges
        }
    }
    
    func setOverlayState(_ state: AudioButtonOverlayState) {
        defer { layoutIfNeeded() }
        aHeightConstraint?.constant = state.height
        aWidthConstraint?.constant = state.width
        alpha = state.alpha
        sendButton.setIconColor(.strongLimeGreen, for: [])
        audioButton.setIconColor(.dynamic(scheme: .iconNormal), for: [])
        playButton.setIconColor(.dynamic(scheme: .iconNormal), for: [])
    }
    
    func updateWithRecordingState(_ state: AudioRecordState) {
        audioButton.isHidden = state == .finishedRecording
        playButton.isHidden = state == .recording
        sendButton.isHidden = false
        backgroundView.isHidden = false
    }
    
    func updateWithPlayingState(_ state: PlayingState) {
        let icon: StyleKitIcon = state == .idle ? .play : .stopRecording
        playButton.setIcon(icon, size: .tiny, for: [])
        playButton.accessibilityValue = state.description
    }
    
    @objc func buttonPressed(_ sender: IconButton) {
        let type: AudioButtonOverlayButtonType
        
        if sender == sendButton {
            type = .send
        } else {
            type = playingState == .idle ? .play : .stop
        }
        
        buttonHandler?(type)
    }
    
}
