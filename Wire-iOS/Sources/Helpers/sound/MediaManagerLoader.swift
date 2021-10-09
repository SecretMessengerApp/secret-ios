
import Foundation
import avs


// The AVS library consists of several components, those are:
// - FlowManager: the component for establishing the network media flows.
// - MediaManager: the part responsible for audio routing on the device.
// - wcall: the Calling3 implementation.
// The entities must be initialized in certain expected order. The main requirement is that the MediaManager is only
// initialized after the FlowManager.


enum LoadingMessage {
    // Called when the app is starting
    case appStart
    // Called whem the FlowManager is created.
    case flowManagerLoaded
}

enum MediaManagerState {
    // MediaManager is not loaded.
    case initial
    // MediaManager is loaded.
    case loaded
}


// This enum is implementing the redundant Elm architecture state change. There is a single state and it's mutated by
// sending it the messages (there is no way to directly alter the state).
extension MediaManagerState {
    public mutating func send(message: LoadingMessage) {
        switch (self, message) {
        case (.initial, .flowManagerLoaded):
            self = .loaded
            
        default:
            // already loaded
            break
        }
    }
}

final class MediaManagerLoader: NSObject {
    
    private var flowManagerObserver: AnyObject?
    private var state: MediaManagerState = .initial {
        didSet {
            switch state {
            case .loaded:
                self.loadMediaManager()
            default: break
            }
        }
    }
    
    internal func send(message: LoadingMessage) {
        self.state.send(message: message)
    }
    
    private func loadMediaManager() {
        AVSMediaManager.sharedInstance()
        configureMediaManager()
    }
    
    private func configureMediaManager() {
        guard let _ = AVSFlowManager.getInstance(),
                let mediaManager = AVSMediaManager.sharedInstance() else {
            return
        }
        
        mediaManager.configureSounds()
        mediaManager.observeSoundConfigurationChanges()
        mediaManager.isMicrophoneMuted = false
        mediaManager.isSpeakerEnabled = false
    }
    
    override init() {
        super.init()
        flowManagerObserver = NotificationCenter.default.addObserver(forName: FlowManager.AVSFlowManagerCreatedNotification, object: nil, queue: OperationQueue.main, using: { [weak self] _ in
            self?.send(message: .flowManagerLoaded)
        })
        
        if let _ = AVSFlowManager.getInstance() {
            self.send(message: .flowManagerLoaded)
        }
    }
}
