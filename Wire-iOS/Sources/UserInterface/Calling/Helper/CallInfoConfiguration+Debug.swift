
extension CallInfoViewControllerInput  {
    var debugDescription: String {
        return """
        <\(type(of: self))>
        accessoryType: \(accessoryType.showAvatar ? "avatar" : "participants (\(accessoryType.participants.count))")
        degradationState: \(degradationState)
        videoPlaceholderState: \(videoPlaceholderState)
        permissions: \(permissions.canAcceptAudioCalls) \(permissions.isPendingAudioPermissionRequest) \(permissions.canAcceptVideoCalls) \(permissions.isPendingVideoPermissionRequest)
        disableIdleTimer: \(disableIdleTimer)
        canToggleMediaType: \(canToggleMediaType)
        isMuted: \(isMuted)
        isTerminating: \(isTerminating)
        canAccept \(canAccept)
        mediaState: \(mediaState)
        appearance: \(appearance)
        isVideoCall: \(isVideoCall)
        variant: \(variant.rawValue)
        state: \(state)
        isConstantBitRate: \(isConstantBitRate)
        title: \(title)
        """
    }
}

extension CallInfoConfiguration: CustomDebugStringConvertible {}
