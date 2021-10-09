

import Foundation
import UIKit

final class MediaBarViewController: UIViewController {
    private var mediaPlaybackManager: MediaPlaybackManager?
    
    private var mediaBarView: MediaBar? {
        return view as? MediaBar
    }
    
    required init(mediaPlaybackManager: MediaPlaybackManager?) {
        super.init(nibName: nil, bundle: nil)
        
        self.mediaPlaybackManager = mediaPlaybackManager
        self.mediaPlaybackManager?.changeObserver = self
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = MediaBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaBarView?.playPauseButton.addTarget(self, action: #selector(playPause(_:)), for: .touchUpInside)
        mediaBarView?.closeButton.addTarget(self, action: #selector(stop(_:)), for: .touchUpInside)
        
        updatePlayPauseButton()
    }
    
    private func updateTitleLabel() {
        mediaBarView?.titleLabel.text = mediaPlaybackManager?.activeMediaPlayer?.title?.uppercased(with: .current)
    }
    
    func updatePlayPauseButton() {
        let playPauseIcon: StyleKitIcon
        let accessibilityIdentifier: String
        
        if mediaPlaybackManager?.activeMediaPlayer?.state == .playing {
            playPauseIcon = .pause
            accessibilityIdentifier = "mediaBarPauseButton"
        } else {
            playPauseIcon = .play
            accessibilityIdentifier = "mediaBarPlayButton"
        }
        
        mediaBarView?.playPauseButton.setIcon(playPauseIcon, size: .tiny, for: UIControl.State.normal)
        mediaBarView?.playPauseButton.accessibilityIdentifier = accessibilityIdentifier
    }
    
    // MARK: - Actions
    @objc
    private func playPause(_ sender: Any?) {
        if mediaPlaybackManager?.activeMediaPlayer?.state == .playing {
            mediaPlaybackManager?.pause()
        } else {
            mediaPlaybackManager?.play()
        }
    }
    
    @objc
    private func stop(_ sender: Any?) {
        mediaPlaybackManager?.stop()
    }

}

extension MediaBarViewController: MediaPlaybackManagerChangeObserver {
    
    func activeMediaPlayerStateDidChange() {
        updatePlayPauseButton()
    }
}
