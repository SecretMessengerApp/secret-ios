
import Foundation
import AVFoundation
import WireDataModel

/// For playing videos in conversation
/// Controls and observe the state of a AVPlayer instance for integration with the AVSMediaManager
final class MediaPlayerController: NSObject {

    let message: ZMConversationMessage
    var player: AVPlayer?
    weak var delegate: MediaPlayerDelegate?
    fileprivate var playerRateObserver: NSKeyValueObservation?

    init(player: AVPlayer, message: ZMConversationMessage, delegate: MediaPlayerDelegate) {
        self.player = player
        self.message = message
        self.delegate = delegate

        super.init()

        playerRateObserver = player.observe(\AVPlayer.rate) { [weak self] _, _ in
            self?.playerRateChanged()
        }
    }

    func tearDown() {
        playerRateObserver = nil
        delegate?.mediaPlayer(self, didChangeTo: .completed)
    }

    private func playerRateChanged() {
        if player?.rate > 0 {
            delegate?.mediaPlayer(self, didChangeTo: .playing)
        } else {
            delegate?.mediaPlayer(self, didChangeTo: .paused)
        }
    }
}

extension MediaPlayerController: MediaPlayer {

    var title: String? {
        return message.fileMessageData?.filename
    }

    var sourceMessage: ZMConversationMessage? {
        return message
    }

    var state: MediaPlayerState? {
        if player?.rate > 0 {
            return MediaPlayerState.playing
        } else {
            return MediaPlayerState.paused
        }
    }

    func play() {
        player?.play()
    }

    func stop() {
        player?.pause()
    }

    func pause() {
        player?.pause()
    }
}
