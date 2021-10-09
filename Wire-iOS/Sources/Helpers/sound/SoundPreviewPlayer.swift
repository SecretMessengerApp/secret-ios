
import Foundation
import avs

class SoundPreviewPlayer {
    
    fileprivate var mediaManager: AVSMediaManager
    fileprivate var stopTimer: Timer?
    
    init(mediaManager: AVSMediaManager) {
        self.mediaManager = mediaManager
    }
    
    func playPreview(_ mediaManagerSound: MediaManagerSound, limit: TimeInterval = 3) {
        stopTimer?.fire()
        mediaManager.play(sound: mediaManagerSound)
        
        stopTimer = Timer.scheduledTimer(withTimeInterval: limit, repeats: false) { [weak self] _ in
            self?.mediaManager.stop(sound: mediaManagerSound)
            self?.stopTimer = nil
        }
    }
    
}

