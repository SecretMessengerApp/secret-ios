
struct VideoConfiguration: VideoGridConfiguration {
    let floatingVideoStream: VideoStream?
    let videoStreams: [VideoStream]
    let isMuted: Bool
    let networkQuality: NetworkQuality

    init(voiceChannel: VoiceChannel, mediaManager: AVSMediaManagerInterface, isOverlayVisible: Bool) {
        floatingVideoStream = voiceChannel.videoStreamArrangment.preview
        videoStreams = voiceChannel.videoStreamArrangment.grid
        isMuted = mediaManager.isMicrophoneMuted && !isOverlayVisible
        networkQuality = voiceChannel.networkQuality
    }
}

extension VoiceChannel {
    
    private var selfStream: VideoStream? {
        switch (isUnconnectedOutgoingVideoCall, videoState) {
        case (true, _), (_, .started), (_, .badConnection), (_, .screenSharing):
            return .init(stream: ZMUser.selfUser().selfStream, isPaused: false)
        case (_, .paused):
            return .init(stream: ZMUser.selfUser().selfStream, isPaused: true)
        case (_, .stopped):
            return nil
        }
    }
    
    fileprivate var videoStreamArrangment: (preview: VideoStream?, grid: [VideoStream]) {
        guard isEstablished else { return (nil, selfStream.map { [$0] } ?? [] ) }
        
        return arrangeVideoStreams(for: selfStream, participantsStreams: participantsActiveVideoStreams)
    }
    
    private var isEstablished: Bool {
        return state == .established
    }
    
    func arrangeVideoStreams(for selfStream: VideoStream?, participantsStreams: [VideoStream]) -> (preview: VideoStream?, grid: [VideoStream]) {
        guard let selfStream = selfStream else {
            return (nil, participantsStreams)
        }
        
        if 1 == participantsStreams.count {
            return (selfStream, participantsStreams)
        } else {
            return (nil, [selfStream] + participantsStreams)
        }
    }
    
    var participantsActiveVideoStreams: [VideoStream] {
        return participants.compactMap { participant in
            switch participant.state {
            case .connected(let videoState, let clientId) where videoState != .stopped:
                return .init(stream: Stream(userId: participant.user.remoteIdentifier, clientId: clientId), isPaused: videoState == .paused)
            default:
                return nil
            }
        }
    }
    
   private var isUnconnectedOutgoingVideoCall: Bool {
        switch (state, isVideoCall) {
        case (.outgoing, true): return true
        default: return false
        }
    }
}
