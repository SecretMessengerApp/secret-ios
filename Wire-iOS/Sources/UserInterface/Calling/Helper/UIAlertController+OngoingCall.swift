
import UIKit

extension UIAlertController {

    static func ongoingCallJoinCallConfirmation(forceAlertModal: Bool = false, completion: @escaping (Bool) -> Void) -> UIAlertController {
        return ongoingCallConfirmation(
            titleKey: "call.alert.ongoing.alert_title",
            messageKey: "call.alert.ongoing.join.message",
            buttonTitleKey: "call.alert.ongoing.join.button",
            forceAlertModal: forceAlertModal,
            completion: completion
        )
    }
    
    static func confirmGroupCall(participants: Int, completion: @escaping (Bool) -> Void) -> UIAlertController {
        let controller = UIAlertController(
            title: "conversation.call.many_participants_confirmation.title".localized,
            message: "conversation.call.many_participants_confirmation.message".localized(args: participants),
            preferredStyle: .alert
        )
        
        controller.addAction(.cancel { completion(false) })
        
        let sendAction = UIAlertAction(
            title: "conversation.call.many_participants_confirmation.call".localized,
            style: .default,
            handler: { _ in completion(true) }
        )
        
        controller.addAction(sendAction)
        return controller
    }
    
    // MARK: - Helper
    
    private static func ongoingCallConfirmation(
        titleKey: String,
        messageKey: String,
        buttonTitleKey: String,
        forceAlertModal: Bool,
        completion: @escaping (Bool) -> Void
        ) -> UIAlertController {

        let defaultStyle: UIAlertController.Style = .alert
        let effectiveStyle = forceAlertModal ? .alert : defaultStyle

        let controller = UIAlertController(
            title: effectiveStyle == .alert ? titleKey.localized : messageKey.localized,
            message: effectiveStyle == .alert ? messageKey.localized : nil,
            preferredStyle: effectiveStyle
        )
        controller.addAction(.init(title: buttonTitleKey.localized, style: .default) { _ in completion(true) })
        controller.addAction(.cancel { completion(false) })
        return controller
    }

}
