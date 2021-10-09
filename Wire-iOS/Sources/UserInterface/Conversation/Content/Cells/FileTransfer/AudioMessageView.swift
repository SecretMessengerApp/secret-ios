
import Foundation
import Cartography
import UIKit
import WireSystem
import WireDataModel
import avs

private let zmLog = ZMSLog(tag: "UI")

class AudioMessageView: UIView, TransferView {
    var fileMessage: ZMConversationMessage?
    weak var delegate: TransferViewDelegate?
    private weak var mediaPlaybackManager: MediaPlaybackManager?
    
    var audioTrackPlayer: AudioTrackPlayer? {
        let mediaManager = mediaPlaybackManager ?? AppDelegate.shared.mediaPlaybackManager
        let audioTrackPlayer = mediaManager?.audioTrackPlayer
        return audioTrackPlayer
    }

    private let downloadProgressView = CircularProgressView()
    let playButton: IconButton = {
        let button = IconButton()
        button.setIconColor(.white, for: .normal)
        return button
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = (UIFont.smallSemiboldFont).monospaced()
        label.textColor = .dynamic(scheme: .title)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.accessibilityIdentifier = "AudioTimeLabel"

        return label
    }()

    let playerProgressView: ProgressView = {
        let progressView = ProgressView()
        progressView.backgroundColor = .dynamic(scheme: .separator)
        progressView.tintColor = .accent()

        return progressView
    }()

    let waveformProgressView: WaveformProgressView = {
        let waveformProgressView = WaveformProgressView()
//        waveformProgressView.backgroundColor = .from(scheme: .placeholderBackground)

        return waveformProgressView
    }()
    private let loadingView = ThreeDotsLoadingView()

    var allViews: [UIView] = []

    private var expectingDownload: Bool = false

    private var proximityMonitorManager: ProximityMonitorManager? {
        return ZClientViewController.shared?.proximityMonitorManager
    }

    private var callStateObserverToken: Any?
    /// flag for resume audio player after incoming call
    private var isPausedForIncomingCall: Bool

    
    init(mediaPlaybackManager: MediaPlaybackManager? = nil) {
        isPausedForIncomingCall = false
        self.mediaPlaybackManager = mediaPlaybackManager

        super.init(frame: .zero)
//        backgroundColor = .from(scheme: .placeholderBackground)

        self.playButton.addTarget(self, action: #selector(AudioMessageView.onActionButtonPressed(_:)), for: .touchUpInside)
        self.playButton.accessibilityLabel = "content.message.audio_message.accessibility".localized
        self.playButton.accessibilityIdentifier = "AudioActionButton"
        self.playButton.layer.masksToBounds = true
        
        self.downloadProgressView.isUserInteractionEnabled = false
        self.downloadProgressView.accessibilityIdentifier = "AudioProgressView"

        self.playerProgressView.setDeterministic(true, animated: false)
        self.playerProgressView.accessibilityIdentifier = "PlayerProgressView"
        
        self.loadingView.isHidden = true
        
        self.allViews = [self.playButton, self.timeLabel, self.downloadProgressView, self.playerProgressView, self.waveformProgressView, self.loadingView]
        self.allViews.forEach(self.addSubview)

        self.createConstraints()
        
        var currentElements = self.accessibilityElements ?? []
        currentElements.append(contentsOf: [playButton, timeLabel])
        self.accessibilityElements = currentElements
        
        setNeedsLayout()
        layoutIfNeeded()

        if let session = ZMUserSession.shared() {
            callStateObserverToken = WireCallCenterV3.addCallStateObserver(observer: self, userSession: session)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 56)
    }
    
    private func createConstraints() {
        constrain(self, self.playButton, self.timeLabel) { selfView, playButton, timeLabel in
            selfView.height == 56
            
            playButton.left == selfView.left + 20
            playButton.centerY == selfView.centerY
            playButton.width == 32
            playButton.height == playButton.width
            
            timeLabel.left == playButton.right + 12
            timeLabel.centerY == selfView.centerY
            timeLabel.width >= 32
        }
        
        constrain(self.downloadProgressView, self.playButton) { downloadProgressView, playButton in
            downloadProgressView.center == playButton.center
            downloadProgressView.width == playButton.width - 2
            downloadProgressView.height == playButton.height - 2
        }
        
        constrain(self, self.playerProgressView, self.timeLabel, self.waveformProgressView, self.loadingView) { selfView, playerProgressView, timeLabel, waveformProgressView, loadingView in
            playerProgressView.centerY == selfView.centerY
            playerProgressView.left == timeLabel.right + 12
            playerProgressView.right == selfView.right - 20
            playerProgressView.height == 1
            
            waveformProgressView.centerY == selfView.centerY
            waveformProgressView.left == playerProgressView.left
            waveformProgressView.right == playerProgressView.right
            waveformProgressView.height == 32
            
            loadingView.center == selfView.center
        }
        
    }
    
    override var tintColor: UIColor! {
        didSet {
            self.downloadProgressView.tintColor = self.tintColor
        }
    }
    
    func stopProximitySensor() {
        self.proximityMonitorManager?.stopListening()
    }
    
    func configure(for message: ZMConversationMessage, isInitial: Bool) {
        self.fileMessage = message
        
        guard let fileMessageData = message.fileMessageData else {
            return
        }
        
        if isInitial {
            self.expectingDownload = false
        } else {
            if fileMessageData.downloadState == .downloaded && self.expectingDownload {
                self.playTrack()
                self.expectingDownload = false
            }
        }
        
        self.configureVisibleViews(forFileMessageData: fileMessageData, isInitial: isInitial)
        self.updateTimeLabel()
        
        if self.isOwnTrackPlayingInAudioPlayer() {
            self.updateActivePlayerProgressAnimated(false)
            self.updateActivePlayButton()
        } else {
            self.playerProgressView.setProgress(0, animated: false)
            self.waveformProgressView.setProgress(0, animated: false)
        }
    }
    
    func willDeleteMessage() {
        proximityMonitorManager?.stopListening()
        guard let player = audioTrackPlayer, let source = player.sourceMessage, source.isEqual(self.fileMessage) else { return }
        player.stop()
    }
    
    private func configureVisibleViews(forFileMessageData fileMessageData: ZMFileMessageData, isInitial: Bool) {
        guard let fileMessage = self.fileMessage,
            let state = FileMessageViewState.fromConversationMessage(fileMessage) else { return }
        
        var visibleViews = [self.playButton, self.timeLabel]
        
        if (fileMessageData.normalizedLoudness?.count ?? 0 > 0) {
            waveformProgressView.samples = fileMessageData.normalizedLoudness ?? []
            if let accentColor = fileMessage.sender?.accentColor {
                waveformProgressView.barColor = accentColor
                waveformProgressView.highlightedBarColor = UIColor.gray
            }
            visibleViews.append(self.waveformProgressView)
        } else {
            visibleViews.append(self.playerProgressView)
        }
        
        switch state {
        case .obfuscated: visibleViews = []
        case .unavailable: visibleViews = [self.loadingView]
        case .downloading, .uploading:
            visibleViews.append(self.downloadProgressView)
            self.downloadProgressView.setProgress(fileMessageData.progress, animated: !isInitial)
        default:
            break
        }
        
        if let viewsState = state.viewsStateForAudio() {

//            self.playButton.isEnabled = true
            self.playButton.setIcon(viewsState.playButtonIcon, size: .tiny, for: .normal)
            self.playButton.backgroundColor = viewsState.playButtonBackgroundColor
            self.playButton.accessibilityValue = viewsState.playButtonIcon == .play ? "play" : "pause"
        }
        
        updateVisibleViews(allViews, visibleViews: visibleViews, animated: !loadingView.isHidden)
    }

    func updateTimeLabel() {

        var duration: Int? = .none
        
        if self.isOwnTrackPlayingInAudioPlayer(), let audioTrackPlayer = self.audioTrackPlayer, audioTrackPlayer.isInProcess {
            duration = Int(audioTrackPlayer.elapsedTime)
        }
        else {
            guard let message = self.fileMessage,
                let fileMessageData = message.fileMessageData else {
                    return
            }
            if fileMessageData.durationMilliseconds != 0 {
                duration = Int(roundf(Float(fileMessageData.durationMilliseconds) / 1000.0))
            }
        }
        
        if let durationUnboxed = duration {
            let (seconds, minutes) = (durationUnboxed % 60, durationUnboxed / 60)
            let time = String(format: "%d:%02d", minutes, seconds)
            self.timeLabel.text = time
        } else {
            self.timeLabel.text = ""
        }
        self.timeLabel.accessibilityValue = self.timeLabel.text
    }
    
    private func updateActivePlayButton() {
        guard let audioTrackPlayer = self.audioTrackPlayer else { return }
        
        self.playButton.backgroundColor = FileMessageViewState.normalColor
        
        if audioTrackPlayer.isPlaying {
            self.playButton.setIcon(.pause, size: .tiny, for: [])
            self.playButton.accessibilityValue = "pause"
        } else {
            self.playButton.setIcon(.play, size: .tiny, for: [])
            self.playButton.accessibilityValue = "play"
        }
    }
    
    private func updateInactivePlayer() {
        self.playButton.backgroundColor = FileMessageViewState.normalColor
        self.playButton.setIcon(.play, size: .tiny, for: [])
        self.playButton.accessibilityValue = "play"
        
        self.playerProgressView.setProgress(0, animated: false)
        self.waveformProgressView.setProgress(0, animated: false)
    }
    
    func updateActivePlayerProgressAnimated(_ animated: Bool) {
        guard let audioTrackPlayer = self.audioTrackPlayer else { return }
        
        let progress: Float
        var animated = animated
        
        if abs(1 - audioTrackPlayer.progress) < 0.01 {
            progress = 0
            animated = false
        } else {
            progress = Float(audioTrackPlayer.progress)
        }
        
        self.playerProgressView.setProgress(progress, animated: animated)
        self.waveformProgressView.setProgress(progress, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.playButton.layer.cornerRadius = self.playButton.bounds.size.width / 2.0
    }
    
    func stopPlaying() {
        guard let player = self.audioTrackPlayer, let source = player.sourceMessage, source.isEqual(self.fileMessage) else { return }
        player.pause()
    }
    
    private func playTrack() {
        let userSession = ZMUserSession.shared()
        guard let fileMessage = self.fileMessage,
              let fileMessageData = fileMessage.fileMessageData,
              let audioTrackPlayer = self.audioTrackPlayer,
              userSession == nil || userSession!.isCallOngoing == false else {
            return
        }
        
        self.proximityMonitorManager?.stateChanged = proximityStateDidChange
        
        let audioTrackPlayingSame = audioTrackPlayer.sourceMessage?.isEqual(self.fileMessage) ?? false
        
        // first play
        if let track = fileMessage.audioTrack(), !audioTrackPlayingSame {
            audioTrackPlayer.pause()
            audioTrackPlayer.audioTrackPlayerDelegate?.stateDidChange(audioTrackPlayer, state: .completed)
            audioTrackPlayer.load(track, sourceMessage: fileMessage) { [weak self] success, error in
                if success {
                    audioTrackPlayer.audioTrackPlayerDelegate = self
                    self?.setAudioOutput(earpiece: false)
                    audioTrackPlayer.play()
                    let duration = TimeInterval(Float(fileMessageData.durationMilliseconds) / 1000.0)
                    let earliestEndDate = Date(timeIntervalSinceNow: duration)
                    self?.extendEphemeralTimerIfNeeded(to: earliestEndDate)
                } else {
                    zmLog.warn("Cannot load track \(track): \(String(describing: error))")
                }
            }
        } else {
            // pausing and restarting
            if audioTrackPlayer.isPlaying {
                audioTrackPlayer.pause()
            } else {
                audioTrackPlayer.play()
            }
        }
    }
    
    /// Extend the ephemeral timer to the given date iff the audio message
    /// is ephemeral and it would exceed its destruction date.
    private func extendEphemeralTimerIfNeeded(to endDate: Date) {
        guard let destructionDate = fileMessage?.destructionDate,
            endDate > destructionDate,
            let assetMsg = fileMessage as? ZMAssetClientMessage
            else { return }
        
        assetMsg.extendDestructionTimer(to: endDate)
    }
    
    /// Check if the audioTrackPlayer is playing my track
    ///
    /// - Returns: true if audioTrackPlayer is playing the audio of this view (not other instance of AudioMessgeView or other audio playing object)
    func isOwnTrackPlayingInAudioPlayer() -> Bool {
        guard let message = self.fileMessage,
            let audioTrack = message.audioTrack(),
            let audioTrackPlayer = self.audioTrackPlayer
            else {
                return false
        }
        
        let audioTrackPlayingSame = audioTrackPlayer.sourceMessage?.isEqual(self.fileMessage) ?? false
        return audioTrackPlayingSame && (audioTrackPlayer.audioTrack?.isEqual(audioTrack) ?? false)
    }

    // MARK: - Actions
    
    @objc func onActionButtonPressed(_ sender: UIButton) {
        isPausedForIncomingCall = false

        guard let fileMessage = self.fileMessage, let fileMessageData = fileMessage.fileMessageData else { return }
        
        switch(fileMessageData.transferState) {
        case .uploading:
            if .none != fileMessageData.fileURL {
                self.delegate?.transferView(self, didSelect: .cancel)
            }
        case .uploadingCancelled, .uploadingFailed:
            if .none != fileMessageData.fileURL {
                self.delegate?.transferView(self, didSelect: .resend)
            }
        case .uploaded:
            ZMUserSession.shared()?.enqueueChanges {
                fileMessage.markAsPlayed()
            }
            switch fileMessageData.downloadState {
            case .remote:
                self.expectingDownload = true
                ZMUserSession.shared()?.enqueueChanges(fileMessageData.requestFileDownload)
            case .downloaded:
                playTrack()
            case .downloading:
                self.downloadProgressView.setProgress(0, animated: false)
                self.delegate?.transferView(self, didSelect: .cancel)
            }
        }
    }
    
    // MARK: - Audio state observer
    func audioProgressChanged() {
        DispatchQueue.main.async {
            if self.isOwnTrackPlayingInAudioPlayer() {
                self.updateActivePlayerProgressAnimated(false)
                self.updateTimeLabel()
            }
        }
    }
    
    
    ///  Observer function for audioTrackPlayer's keyPath "state".
    ///  This function updates the visual progress of the audio, play button icon image, time label and proximity sensor's sate.
    ///  Notice: when there are more then 1 instance of this class exists, this function will be called in every instance.
    ///          This function may called from background thread (in case incoming call).
    ///
    /// - Parameter change: a dictionary with KVP kind and new (enum MediaPlayerState: 0 = ready, 1 = play, 2 = pause, 3 = completed, 4 = error)
    @objc dynamic private func audioPlayerStateChanged(_ change: NSDictionary) {
        DispatchQueue.main.async {
            if self.isOwnTrackPlayingInAudioPlayer() {
                self.updateActivePlayerProgressAnimated(false)
                self.updateActivePlayButton()
                self.updateTimeLabel()
                self.updateProximityObserverState()
            }
            /// when state is completed, there is no info about it is own track or not. Update the time label in this case anyway (set to the length of own audio track)
            else if let new = change["new"] as? Int, let state = MediaPlayerState(rawValue: new), state == .completed {
                self.updateTimeLabel()
            }
        }
    }

    private func updateUI(state: MediaPlayerState?) {
        if isOwnTrackPlayingInAudioPlayer() {
            updateActivePlayerProgressAnimated(false)
            updateActivePlayButton()
            updateTimeLabel()
            updateProximityObserverState()
        }
            /// when state is completed, there is no info about it is own track or not. Update the time label in this case anyway (set to the length of own audio track)
        else if state == .completed {
            updateTimeLabel()
        } else {
            updateInactivePlayer()
        }
    }

    // MARK: - Proximity Listener
    
    private func updateProximityObserverState() {
        guard let audioTrackPlayer = self.audioTrackPlayer, isOwnTrackPlayingInAudioPlayer() else { return }
        
        if audioTrackPlayer.isPlaying {
            proximityMonitorManager?.startListening()
        } else {
            proximityMonitorManager?.stopListening()
        }
    }
    
    private func setAudioOutput(earpiece: Bool) {
        do {
            if earpiece {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default)
                AVSMediaManager.sharedInstance().playbackRoute = .builtIn
            } else {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                AVSMediaManager.sharedInstance().playbackRoute = .speaker
            }
        } catch {
            zmLog.error("Cannot set AVAudioSession category: \(error)")
        }
    }
    
    func proximityStateDidChange(_ raisedToEar: Bool) {
        setAudioOutput(earpiece: raisedToEar)
    }
}

// MARK: - WireCallCenterCallStateObserver

extension AudioMessageView: WireCallCenterCallStateObserver {

    func callCenterDidChange(callState: CallState,
                             conversation: ZMConversation,
                             caller: UserType,
                             timestamp: Date?,
                             previousCallState: CallState?) {
        guard let player = audioTrackPlayer else { return }
        guard isOwnTrackPlayingInAudioPlayer() else { return }

        // Pause the audio player when call is incoming to prevent the audio player is reset.
        // Resume playing when the call is terminating (and the audio is paused by this method)
        switch (previousCallState, callState) {
        case (_, .incoming):
            if player.isPlaying {
                player.pause()
                isPausedForIncomingCall = true
            }
        case (.incoming?, .terminating):
            if isPausedForIncomingCall && !player.isPlaying {
                player.play()
            }
            isPausedForIncomingCall = false
        default:
            break
        }
    }
}

extension AudioMessageView: AudioTrackPlayerDelegate {
    func progressDidChange(_ audioTrackPlayer: AudioTrackPlayer, progress: Double) {
        audioProgressChanged()
    }

    func stateDidChange(_ audioTrackPlayer: AudioTrackPlayer, state: MediaPlayerState?) {
        ///  Updates the visual progress of the audio, play button icon image, time label and proximity sensor's sate.
        ///  Notice: when there are more then 1 instance of this class exists, this function will be called in every instance.
        ///          This function may called from background thread (in case incoming call).
        DispatchQueue.main.async { [weak self] in
            self?.updateUI(state: state)
        }
    }
}
