
import Foundation
import UIKit

protocol CallQualityControllerDelegate: class {
    func dismissCurrentSurveyIfNeeded()
    func callQualityControllerDidScheduleSurvey(with controller: CallQualityViewController)
    func callQualityControllerDidScheduleDebugAlert()
}

/**
 * Observes call state to prompt the user for call quality feedback when appropriate.
 */

final class CallQualityController: NSObject {
    
    weak var delegate: CallQualityControllerDelegate? = nil

    fileprivate var answeredCalls: [UUID: Date] = [:]
    fileprivate var token: Any?
    
    override init() {
        super.init()
        
        if let userSession = ZMUserSession.shared() {
            token = WireCallCenterV3.addCallStateObserver(observer: self, userSession: userSession)
        }
    }

    // MARK: - Configuration

    /// Whether we use a maxmimum budget for call surveying per user.
    var usesCallSurveyBudget: Bool = true

    /// The range of scores where we consider the call quality is not satisfying.
    let callQualityRejectionRange = 1 ... 2

    /// The minimum duration for calls to trigger a survey.
    let miminumSignificantCallDuration: TimeInterval = 5*60

    /**
     * Whether the call quality survey can be presented.
     *
     * We only present the call quality survey for internal users.
     */

    var canPresentCallQualitySurvey: Bool {
        return Bundle.developerModeEnabled && !AutomationHelper.sharedHelper.disableCallQualitySurvey
    }

    // MARK: - Events

    /**
     * Handles the start of the call in the specified conversation. Call this method when the call
     * is established.
     * - parameter conversation: The conversation where the call is ongoing.
     */

    private func handleCallStart(in conversation: ZMConversation) {
        answeredCalls[conversation.remoteIdentifier!] = Date()
    }

    /**
     * Handles the end of a call in the specified conversation.
     * - parameter conversation: The conversation where the call ended.
     * - parameter reason: The reason why the call ended.
     * - parameter eventDate: The date when the call ended.
     */

    private func handleCallCompletion(in conversation: ZMConversation, reason: CallClosedReason, eventDate: Date) {
        // Check for the call start date (do not show feedback for unanswered calls)
        guard let callStartDate = answeredCalls[conversation.remoteIdentifier!] else {
            return
        }

        switch reason {
        case .normal, .stillOngoing:
            handleCallSuccess(callStartDate: callStartDate, callEndDate: eventDate)
        case .anweredElsewhere: break;
        default:
            handleCallFailure()
        }

        answeredCalls[conversation.remoteIdentifier!] = nil
    }

    /// Presents the call quality survey after a successful call.
    private func handleCallSuccess(callStartDate: Date, callEndDate: Date) {
        let callDuration = callEndDate.timeIntervalSince(callStartDate)

        guard callDuration >= miminumSignificantCallDuration else {
            Analytics.shared().tagCallQualityReview(.notDisplayed(reason: .callTooShort, duration: Int(callDuration)))
            return
        }

        guard self.canRequestSurvey() else {
            CallQualityController.updateIsNextTimeShowingCallSurvey()
            Analytics.shared().tagCallQualityReview(.notDisplayed(reason: .muted, duration: Int(callDuration)))
            return
        }

        let qualityController = CallQualityViewController.configureSurveyController(callDuration: callDuration)
        qualityController.delegate = self
        qualityController.transitioningDelegate = self

        delegate?.callQualityControllerDidScheduleSurvey(with: qualityController)
    }

    /// Presents the debug log prompt after a call failure.
    private func handleCallFailure() {
        delegate?.callQualityControllerDidScheduleDebugAlert()
    }

    /// Presents the debug log prompt after a user quality rejection.
    private func handleCallQualityRejection() {
        DebugAlert.showSendLogsMessage(message: "Sending the debug logs can help us improve the quality of calls and the overall app experience.")
    }

}

// MARK: - Call State

extension CallQualityController: WireCallCenterCallStateObserver {
    
    func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?) {
        guard canPresentCallQualitySurvey else { return }
        let eventDate = Date()

        switch callState {
        case .established:
            handleCallStart(in: conversation)
        case .terminating(let terminationReason):
            handleCallCompletion(in: conversation, reason: terminationReason, eventDate: eventDate)
        case .incoming(_, let shouldRing, _):
            if shouldRing {
                delegate?.dismissCurrentSurveyIfNeeded()
            }
        default:
            return
        }
    }
    
}

// MARK: - User Input

extension CallQualityController : CallQualityViewControllerDelegate {

    func callQualityController(_ controller: CallQualityViewController, didSelect score: Int) {
        controller.dismiss(animated: true) {
            if self.callQualityRejectionRange.contains(score) {
                self.handleCallQualityRejection()
            }
        }

        CallQualityController.updateIsNextTimeShowingCallSurvey()
        Analytics.shared().tagCallQualityReview(.answered(score: score, duration: controller.callDuration))
    }

    func callQualityControllerDidFinishWithoutScore(_ controller: CallQualityViewController) {
        CallQualityController.updateIsNextTimeShowingCallSurvey()
        Analytics.shared().tagCallQualityReview(.dismissed(duration: controller.callDuration))
        controller.dismiss(animated: true, completion: nil)
    }

}

// MARK: - Transitions

extension CallQualityController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return (presented is CallQualityViewController) ? CallQualityPresentationTransition() : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return (dismissed is CallQualityViewController) ? CallQualityDismissalTransition() : nil
    }
    
}
