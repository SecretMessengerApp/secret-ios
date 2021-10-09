
import Foundation

protocol MediaPlayerDelegate: class {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didChangeTo state: MediaPlayerState)
}
