
import UIKit
import WireDataModel

typealias ViewControllerPresenter = (UIViewController, Bool, (() -> Void)?) -> Void
typealias SuggestedStateChangeHandler = (LegalHoldDisclosureController.DisclosureState) -> Void

enum LegalHoldAlertFactory {

    static func makeLegalHoldDeactivatedAlert(for user: SelfUserType, suggestedStateChangeHandler: SuggestedStateChangeHandler?) -> UIAlertController {
        return UIAlertController.alertWithOKButton(
            title: "legal_hold.deactivated.title".localized,
            message: "legal_hold.deactivated.message".localized,
            okActionHandler: { _ in
                user.acceptLegalHoldChangeAlert()
                suggestedStateChangeHandler?(.none)
            }
        )
    }

    static func makeLegalHoldActivatedAlert(for user: SelfUserType, suggestedStateChangeHandler: SuggestedStateChangeHandler?) -> UIAlertController {
        let alert = UIAlertController.alertWithOKButton(
            title: "legalhold_active.alert.title".localized,
            message: "legalhold_active.alert.message".localized,
            okActionHandler: { _ in
                user.acceptLegalHoldChangeAlert()
                suggestedStateChangeHandler?(.none)
            }
        )

        return alert
    }

    static func makeLegalHoldActivationAlert(for legalHoldRequest: LegalHoldRequest, user: SelfUserType, suggestedStateChangeHandler: SuggestedStateChangeHandler?) -> UIAlertController {
        func handleLegalHoldActivationResult(_ error: LegalHoldActivationError?) {
            UIApplication.shared.topmostViewController()?.showLoadingView = false

            switch error {
            case .invalidPassword?:
                user.acceptLegalHoldChangeAlert()

                let alert = UIAlertController.alertWithOKButton(
                    title: "legalhold_request.alert.error_wrong_password".localized,
                    message: "general.failure.try_again".localized,
                    okActionHandler: { _ in suggestedStateChangeHandler?(.warningAboutPendingRequest(legalHoldRequest)) }
                )

                suggestedStateChangeHandler?(.warningAboutAcceptationResult(alert))

            case .some:
                user.acceptLegalHoldChangeAlert()

                let alert = UIAlertController.alertWithOKButton(
                    title: "general.failure".localized,
                    message: "general.failure.try_again".localized,
                    okActionHandler: { _ in suggestedStateChangeHandler?(.warningAboutPendingRequest(legalHoldRequest)) }
                )

                suggestedStateChangeHandler?(.warningAboutAcceptationResult(alert))

            case .none:
                user.acceptLegalHoldChangeAlert()
                suggestedStateChangeHandler?(.none)
            }
        }

        let cancellationHandler = {
            user.acceptLegalHoldChangeAlert()
            suggestedStateChangeHandler?(.none)
        }

        let request = user.makeLegalHoldInputRequest(for: legalHoldRequest, cancellationHandler: cancellationHandler) { password in
            UIApplication.shared.topmostViewController()?.showLoadingView = true
            suggestedStateChangeHandler?(.acceptingRequest)

            ZMUserSession.shared()?.accept(legalHoldRequest: legalHoldRequest, password: password) { error in
                handleLegalHoldActivationResult(error)
            }
        }

        return UIAlertController(inputRequest: request)
    }

}

// MARK: - SelfLegalHoldSubject + Accepting Alert

extension SelfLegalHoldSubject {

    fileprivate func acceptLegalHoldChangeAlert() {
        ZMUserSession.shared()?.performChanges {
            self.acknowledgeLegalHoldStatus()
        }
    }

}
