
extension VideoState {

    var toggledState: VideoState {
        return isSending ? .stopped : .started
    }
    
    var isSending: Bool {
        switch self {
        case .started, .paused, .badConnection, .screenSharing: return true
        case .stopped: return false
        }
    }
    
    var isPaused: Bool {
        switch self {
        case .paused: return true
        default: return false
        }
    }

}
