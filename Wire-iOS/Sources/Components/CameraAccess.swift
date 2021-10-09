
import UIKit

enum CameraAccessFeature: Int {
    case recordVideo
    case recordAudioMessage
    case takePhoto
}

class CameraAccess: NSObject {


    /// if there is an on going call, show a alert and return true
    ///
    /// - Parameters:
    ///   - feature: a CameraAccessFeature for alert's message
    ///   - viewController: the viewController to present the alert
    /// - Returns: true is there is an on going call and a alert is shown
    static func displayAlertIfOngoingCall(at feature: CameraAccessFeature, from viewController: UIViewController) -> Bool {
        if ZMUserSession.shared()?.isCallOngoing == true {
            CameraAccess.displayCameraAlertForOngoingCall(at: feature, from: viewController)
            return true
        }
        
        return false
    }
    
    static func displayCameraAlertForOngoingCall(at feature: CameraAccessFeature, from viewController: UIViewController) {
        let alert = UIAlertController.alertWithOKButton(title: "conversation.input_bar.ongoing_call_alert.title".localized,
                                            message: feature.message.localized)

        viewController.present(alert, animated: true)
    }
}

fileprivate extension CameraAccessFeature {
    var message: String {
        switch self {
        case .recordVideo: return "conversation.input_bar.ongoing_call_alert.video.message"
        case .recordAudioMessage: return "conversation.input_bar.ongoing_call_alert.audio.message"
        case .takePhoto: return "conversation.input_bar.ongoing_call_alert.photo.message"
        }
    }
}
