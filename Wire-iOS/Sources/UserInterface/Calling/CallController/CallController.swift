
import Foundation
import UIKit
import WireDataModel

final class CallController: NSObject {

    weak var targetViewController: UIViewController? = nil
    private(set) weak var activeCallViewController: ActiveCallViewController?

    fileprivate let callQualityController = CallQualityController()
    fileprivate var scheduledPostCallAction: (()->Void)?
    fileprivate var observerTokens: [Any] = []
    fileprivate var minimizedCall: ZMConversation? = nil
    fileprivate var topOverlayCall: ZMConversation? = nil {
        didSet {
            guard  topOverlayCall != oldValue else { return }
            
            if let conversation = topOverlayCall {
                let callTopOverlayController = CallTopOverlayController(conversation: conversation)
                callTopOverlayController.delegate = self
                ZClientViewController.shared?.setTopOverlay(to: callTopOverlayController)
            } else {
                ZClientViewController.shared?.setTopOverlay(to: nil)
            }
        }
    }
    
    override init() {
        super.init()
        callQualityController.delegate = self

        if let userSession = ZMUserSession.shared() {
            observerTokens.append(WireCallCenterV3.addCallStateObserver(observer: self, userSession: userSession))
            observerTokens.append(WireCallCenterV3.addCallErrorObserver(observer: self, userSession: userSession))
        }
    }
}

extension CallController: WireCallCenterCallStateObserver {
    
    func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?) {
        updateState()
    }
    
    func updateState() {
        guard let userSession = ZMUserSession.shared() else { return }
        
        if let priorityCallConversation = userSession.priorityCallConversation {
            topOverlayCall = priorityCallConversation
            
            if priorityCallConversation == minimizedCall {
                minimizeCall(in: priorityCallConversation)
            } else {
                let animated: Bool
                if SessionManager.shared?.callNotificationStyle == .callKit {
                    switch priorityCallConversation.voiceChannel?.state {
                    case .outgoing?:
                        animated = true
                    default:
                        animated = false // We don't want animate when transition from CallKit screen
                    }
                } else {
                    animated =  true
                }
                presentCall(in: priorityCallConversation, animated: animated)
            }
        } else {
            dismissCall()
        }
    }
    
    func minimizeCall(animated: Bool, completion: (() -> Void)?) {
        guard let activeCallViewController = activeCallViewController else {
            completion?()
            return
        }
    
        activeCallViewController.dismiss(animated: animated, completion: completion)
    }
    
    fileprivate func minimizeCall(in conversation: ZMConversation) {
        activeCallViewController?.dismiss(animated: true)
    }
    
    fileprivate  func presentCall(in conversation: ZMConversation, animated: Bool = true) {
        guard activeCallViewController == nil else { return }
        guard let voiceChannel = conversation.voiceChannel else { return }
        
        if minimizedCall == conversation {
            minimizedCall = nil
        }
        
        let viewController = ActiveCallViewController(voiceChannel: voiceChannel)
        viewController.dismisser = self
        activeCallViewController = viewController
        
        // NOTE: We resign first reponder for the input bar since it will attempt to restore
        // first responder when the call overlay is interactively dismissed but canceled.
        UIResponder.currentFirst?.resignFirstResponder()
        
        let modalVC = ModalPresentationViewController(viewController: viewController)
        modalVC.modalPresentationStyle = .fullScreen
        targetViewController?.present(modalVC, animated: animated)
    }
    
    fileprivate func dismissCall() {
        minimizedCall = nil
        topOverlayCall = nil

        activeCallViewController?.dismiss(animated: true) {
            if let postCallAction = self.scheduledPostCallAction {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    postCallAction()
                    self.scheduledPostCallAction = nil
                }
            }
        }
        
        activeCallViewController = nil
    }
}

extension CallController: ViewControllerDismisser {
    
    func dismiss(viewController: UIViewController, completion: (() -> ())?) {
        guard let callViewController = viewController as? CallViewController, let conversation = callViewController.conversation else { return }
        
        minimizedCall = conversation
        activeCallViewController = nil
    }
    
}

extension CallController: CallTopOverlayControllerDelegate {
    
    func voiceChannelTopOverlayWantsToRestoreCall(_ controller: CallTopOverlayController) {
        presentCall(in: controller.conversation)
    }
    
}

extension CallController: CallQualityControllerDelegate {

    func dismissCurrentSurveyIfNeeded() {
        if let survey = targetViewController?.presentedViewController as? CallQualityViewController {
            survey.dismiss(animated: true, completion: nil)
        }
    }

    func callQualityControllerDidScheduleSurvey(with controller: CallQualityViewController) {
        let presentCallQualityControllerAction: () -> Void = { [weak self] in
            self?.targetViewController?.present(controller, animated: true, completion: nil)
        }
        
        if self.activeCallViewController == nil {
            presentCallQualityControllerAction()
        } else {
            scheduledPostCallAction = presentCallQualityControllerAction
        }
    }
    
    func callQualityControllerDidScheduleDebugAlert() {
        let presentDebugAlertAction: () -> Void = {
            DebugAlert.showSendLogsMessage(message: "The call failed. Sending the debug logs can help us troubleshoot the issue and improve the overall app experience.")
        }
        
        if self.activeCallViewController == nil {
            presentDebugAlertAction()
        } else {
            scheduledPostCallAction = presentDebugAlertAction
        }
    }

}


extension CallController: WireCallCenterCallErrorObserver {
    
    func callCenterDidReceiveCallError(_ error: CallError) {
        guard error == .unknownProtocol else { return }
        
        let alertController = UIAlertController(title: "voice.call_error.unsupported_version.title".localized, message: "voice.call_error.unsupported_version.message".localized, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "force.update.ok_button".localized, style: .default) { (_) in
            UIApplication.shared.open(URL.wr_wireAppOnItunes)
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "voice.call_error.unsupported_version.dismiss".localized, style: .default, handler: nil))
        targetViewController?.present(alertController, animated: true, completion: nil)
    }
}
