

import Foundation
import Cartography
import avs

// MARK: Audio Button

extension ConversationInputBarViewController {
    
    
    func setupCallStateObserver() {
        if let userSession = ZMUserSession.shared() {
            callStateObserverToken = WireCallCenterV3.addCallStateObserver(observer: self, userSession:userSession)
        }
    }

    func setupAppLockedObserver() {

        NotificationCenter.default.addObserver(self,
        selector: #selector(revealRecordKeyboardWhenAppLocked),
        name: .appUnlocked,
        object: .none)

        // If the app is locked and not yet reach the time to unlock and the app became active, reveal the keyboard (it was dismissed when app resign active)
        NotificationCenter.default.addObserver(self, selector: #selector(revealRecordKeyboardWhenAppLocked), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc private func revealRecordKeyboardWhenAppLocked() {
        guard AppLock.isActive,
              !AppLockViewController.isLocked,
              mode == .audioRecord,
              !self.inputBar.textView.isFirstResponder else { return }

        displayRecordKeyboard()
    }
    
    @objc func audioButtonPressed(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else {
            return
        }
        
        if displayAudioMessageAlertIfNeeded() {
            return
        }
        
        switch self.mode {
        case .audioRecord:
            if self.inputBar.textView.isFirstResponder {
                hideInKeyboardAudioRecordViewController()
            } else {
                self.inputBar.textView.becomeFirstResponder()
            }
        default:
            UIApplication.wr_requestOrWarnAboutMicrophoneAccess { accepted in
                if accepted {
                    self.mode = .audioRecord
                    self.inputBar.textView.becomeFirstResponder()
                }
            }
        }
    }
    
    private func displayAudioMessageAlertIfNeeded() -> Bool {
        CameraAccess.displayAlertIfOngoingCall(at:.recordAudioMessage, from:self)
    }
    
    @objc func audioButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        guard self.mode != .audioRecord, !displayAudioMessageAlertIfNeeded() else {
            return
        }

        type(of: self).cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideInlineAudioRecordViewController), object: nil)

        switch sender.state {
        case .began:
            createAudioViewController()
            showAudioRecordViewControllerIfGrantedAccess()
        case .changed:
            audioRecordViewController?.updateWithChangedRecognizer(sender)
        case .ended, .cancelled, .failed:
            audioRecordViewController?.finishRecordingIfNeeded(sender)
        default: break
        }
    }

    fileprivate func showAudioRecordViewControllerIfGrantedAccess() {
        if audioSession.recordPermission == .granted {
            audioRecordViewController?.beginRecording()
            showAudioRecordViewController()
        } else {
            requestMicrophoneAccess()
        }
    }
    
    func createAudioViewController(audioRecorder: AudioRecorderType? = nil) {
        removeAudioViewController()
        
        let audioRecordViewController = AudioRecordViewController(audioRecorder: audioRecorder)
        audioRecordViewController.view.translatesAutoresizingMaskIntoConstraints = false
        audioRecordViewController.delegate = self
        
        let audioRecordViewContainer = UIView()
        audioRecordViewContainer.translatesAutoresizingMaskIntoConstraints = false
        audioRecordViewContainer.backgroundColor = .dynamic(scheme: .background)
        audioRecordViewContainer.isHidden = true
        
        addChild(audioRecordViewController)
        inputBar.addSubview(audioRecordViewContainer)
        audioRecordViewContainer.fitInSuperview()
        audioRecordViewContainer.addSubview(audioRecordViewController.view)
        
        NSLayoutConstraint.activate([
            audioRecordViewController.view.leadingAnchor.constraint(equalTo: audioRecordViewContainer.leadingAnchor),
            audioRecordViewController.view.trailingAnchor.constraint(equalTo: audioRecordViewContainer.trailingAnchor),
            audioRecordViewController.view.bottomAnchor.constraint(equalTo: audioRecordViewContainer.bottomAnchor),
            audioRecordViewController.view.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: -0.5)
        ])
        
        self.audioRecordViewController = audioRecordViewController
        self.audioRecordViewContainer = audioRecordViewContainer
    }
    
    func removeAudioViewController() {
        audioRecordViewController?.removeFromParent()
        audioRecordViewContainer?.removeFromSuperview()
        
        audioRecordViewContainer = nil
        audioRecordViewController = nil
    }
    
    fileprivate func requestMicrophoneAccess() {
        UIApplication.wr_requestOrWarnAboutMicrophoneAccess { (granted) in
            guard granted else { return }
        }
    }
    
    func showAudioRecordViewController(animated: Bool = true) {
        guard let audioRecordViewContainer = self.audioRecordViewContainer,
              let audioRecordViewController = self.audioRecordViewController else {
            return
        }
                
        if animated {
            audioRecordViewController.setOverlayState(.hidden, animated: false)
            UIView.transition(with: inputBar, duration: 0.1, options: [.transitionCrossDissolve, .allowUserInteraction], animations: {
                audioRecordViewContainer.isHidden = false
            }, completion: { _ in
                audioRecordViewController.setOverlayState(.expanded(0), animated: true)
            })
        } else {
            audioRecordViewContainer.isHidden = false
            audioRecordViewController.setOverlayState(.expanded(0), animated: false)
        }
    }
    
    func hideAudioRecordViewController() {
        if self.mode == .audioRecord {
            hideInKeyboardAudioRecordViewController()
        } else {
            removeAudioViewController()
        }
    }
    
    fileprivate func hideInKeyboardAudioRecordViewController() {
        self.inputBar.textView.resignFirstResponder()
        delay(0.3) {
            self.mode = .textInput
        }
    }
    
    @objc private func hideInlineAudioRecordViewController() {
        inputBar.buttonContainer.isHidden = false
        guard let audioRecordViewContainer = self.audioRecordViewContainer else {
            return
        }

        UIView.transition(with: inputBar, duration: 0.2, options: .transitionCrossDissolve, animations: {
            audioRecordViewContainer.isHidden = true
            }, completion: nil)
    }
    
    func hideCameraKeyboardViewController(_ completion: @escaping () -> Void) {
        self.inputBar.textView.resignFirstResponder()
        delay(0.3) {
            self.mode = .textInput
            completion()
        }
    }
}

extension ConversationInputBarViewController: AudioRecordViewControllerDelegate {
    
    func audioRecordViewControllerDidCancel(_ audioRecordViewController: AudioRecordBaseViewController) {
        hideAudioRecordViewController()
    }

    func audioRecordViewControllerDidStartRecording(_ audioRecordViewController: AudioRecordBaseViewController) {
//        if mode != .audioRecord {
//            showAudioRecordViewController()
//        }
    }
    
    func audioRecordViewControllerWantsToSendAudio(_ audioRecordViewController: AudioRecordBaseViewController, recordingURL: URL, duration: TimeInterval, filter: AVSAudioEffectType) {

        uploadFile(at: recordingURL)

        hideAudioRecordViewController()
    }
}



extension ConversationInputBarViewController: WireCallCenterCallStateObserver {
    
    public func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?) {
        let isRecording = audioRecordKeyboardViewController?.isRecording

        switch (callState, isRecording, wasRecordingBeforeCall) {
        case (.incoming(_, true, _), true, _),              // receiving incoming call while audio keyboard is visible
             (.outgoing, true, _):                          // making an outgoing call while audio keyboard is visible
            wasRecordingBeforeCall = true                   // -> remember that the audio keyboard was visible
            callCountWhileCameraKeyboardWasVisible += 1     // -> increment calls in progress counter
        case (.incoming(_, false, _), _, true),             // refusing an incoming call
             (.terminating, _, true):                       // terminating/closing the current call
            callCountWhileCameraKeyboardWasVisible -= 1     // -> decrement calls in progress counter
        default: break
        }

        if 0 == callCountWhileCameraKeyboardWasVisible, wasRecordingBeforeCall {
            displayRecordKeyboard() // -> show the audio record keyboard again
        }
    }

    private func displayRecordKeyboard() {
        // do not show keyboard if conversation list is shown, 
        guard let splitViewController = self.wr_splitViewController,
              let rightViewController = splitViewController.rightViewController,
              splitViewController.isRightViewControllerRevealed,
              rightViewController.isVisible,
              UIApplication.shared.topMostVisibleWindow == AppDelegate.shared.window
            else { return }

        self.wasRecordingBeforeCall = false
        self.mode = .audioRecord
        self.inputBar.textView.becomeFirstResponder()
    }
    
}
