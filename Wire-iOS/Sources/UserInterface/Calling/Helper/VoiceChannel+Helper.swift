
import avs

extension VoiceChannel {

    func toggleMuteState(userSession: ZMUserSession) {
        mute(!AVSMediaManager.sharedInstance().isMicrophoneMuted, userSession: userSession)
    }

}
