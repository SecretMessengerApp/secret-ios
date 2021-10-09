

import Foundation

extension ZMConversationMessage {
    public func audioCanBeSaved() -> Bool {
        if let fileMessageData = self.fileMessageData,
            let _ = fileMessageData.fileURL,
            fileMessageData.isAudio {
            return true
        }
        else {
            return false
        }
    }
    
    func audioTrack() -> AudioTrack? {
        if let fileMessageData = self.fileMessageData
            , fileMessageData.isAudio {
            return self as? AudioTrack
        }
        else {
            return .none
        }
    }
}

extension ZMAssetClientMessage: AudioTrack {
    public var artworkURL: URL! {
        get {
            return .none
        }
    }

    public var title: String? {
        get {
            guard let fileMessageData = self.fileMessageData else { return "" }
            
            return fileMessageData.filename
        }
    }
    public var author: String? {
        get {
            return self.sender?.displayName
        }
    }
    
    public var artwork: UIImage? {
        get {
            return .none
        }
    }
    
    public var duration: TimeInterval {
        get {
            guard let fileMessageData = self.fileMessageData else { return 0 }
            
            return TimeInterval(Float(fileMessageData.durationMilliseconds) / 1000.0)
        }
    }
    
    public var streamURL: URL? {
        get {
            guard let fileMessageData = self.fileMessageData,
                let fileURL = fileMessageData.fileURL else { return .none }
            
            return fileURL as URL?
        }
    }
    
    public var previewStreamURL: URL? {
        get {
            return .none
        }
    }
    
    public var externalURL: URL? {
        get {
            return .none
        }
    }
    
    public var failedToLoad: Bool {
        get {
            return false
        }
        set {
            // no-op
        }
    }
    
    public func fetchArtwork() {
        // no-op
    }
    
}
