
// The ouput actions a `CallInfoViewController` can perform.
enum CallAction {
    case toggleMuteState
    case toggleVideoState
    case alertVideoUnavailable
    case toggleSpeakerState
    case continueDegradedCall
    case acceptCall
    case acceptDegradedCall
    case terminateCall
    case terminateDegradedCall
    case flipCamera
    case minimizeOverlay
    case showParticipantsList
}
