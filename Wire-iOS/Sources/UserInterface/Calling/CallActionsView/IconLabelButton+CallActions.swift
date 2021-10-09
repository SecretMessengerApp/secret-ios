
import UIKit

extension IconLabelButton {

    static func speaker() -> IconLabelButton {
        return .init(
            icon: .speaker,
            label: "voice.speaker_button.title".localized,
            accessibilityIdentifier: "CallSpeakerButton"
        )
    }
    
    static func muteCall() -> IconLabelButton {
        return .init(
            icon: .microphoneWithStrikethrough,
            label: "voice.mute_button.title".localized,
            accessibilityIdentifier: "CallMuteButton"
        )
    }
    
    static func video() -> IconLabelButton {
        return .init(
            icon: .videoCall,
            label: "voice.video_button.title".localized,
            accessibilityIdentifier: "CallVideoButton"
        )
    }
    
    static func flipCamera() -> IconLabelButton {
        return .init(
            icon: .cameraSwitch,
            label: "voice.flip_video_button.title".localized,
            accessibilityIdentifier: "CallFlipCameraButton"
        )
    }
    
}
