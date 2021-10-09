
import UIKit

extension UIViewController {
    
    func showAlert(
        title: String?, message: String,
        okActionHandler: AlertActionHandler? = nil,
        cancelActionHandler: (() -> Void)? = nil
    ) {
        present(
            UIAlertController.alertWithOKCancelButton(
                title: title,
                message: message,
                okActionHandler: okActionHandler,
                cancelActionHandler: cancelActionHandler
            ),
            animated: true
        )
    }
     
    func showAlert(title: String? = nil, message: String, okHandler: AlertActionHandler? = nil) {
        present(UIAlertController.alertWithOKButton(title: title,
                                                    message: message,
                                                    okActionHandler: okHandler), animated: true)

    }
    

    func showAlert(for error: LocalizedError, okHandler: AlertActionHandler? = nil) {
        present(UIAlertController.alertWithOKButton(title: error.errorDescription,
                                                    message: error.failureReason ?? "error.user.unkown_error".localized,
                                                    okActionHandler: okHandler), animated: true)

    }

    func showAlert(for error: Error, okHandler: AlertActionHandler? = nil) {
        let nsError: NSError = error as NSError
        var message = ""

        if nsError.domain == ZMObjectValidationErrorDomain,
            let code: ZMManagedObjectValidationErrorCode = ZMManagedObjectValidationErrorCode(rawValue: nsError.code) {
            switch code {
            case .tooLong:
                message = "error.input.too_long".localized
            case .tooShort:
                message = "error.input.too_short".localized
            case .emailAddressIsInvalid:
                message = "error.email.invalid".localized
            case .phoneNumberContainsInvalidCharacters:
                message = "error.phone.invalid".localized
            default:
                break
            }
        } else if nsError.domain == NSError.ZMUserSessionErrorDomain,
            let code: ZMUserSessionErrorCode = ZMUserSessionErrorCode(rawValue: UInt(nsError.code)) {
            switch code {
            case .noError:
                message = ""
            case .needsCredentials:
                message = "error.user.needs_credentials".localized
            case .invalidCredentials:
                message = "error.user.invalid_credentials".localized
            case .accountIsPendingActivation:
                message = "error.user.account_pending_activation".localized
            case .networkError:
                message = "error.user.network_error".localized
            case .emailIsAlreadyRegistered:
                message = "error.user.email_is_taken".localized
            case .phoneNumberIsAlreadyRegistered:
                message = "error.user.phone_is_taken".localized
            case .invalidPhoneNumberVerificationCode, .invalidActivationCode:
                message = "error.user.phone_code_invalid".localized
            case .registrationDidFailWithUnknownError:
                message = "error.user.registration_unknown_error".localized
            case .invalidPhoneNumber:
                message = "error.phone.invalid".localized
            case .invalidEmail:
                message = "error.email.invalid".localized
            case .codeRequestIsAlreadyPending:
                message = "error.user.phone_code_too_many".localized
            case .clientDeletedRemotely:
                message = "error.user.device_deleted_remotely".localized
            case .lastUserIdentityCantBeDeleted:
                message = "error.user.last_identity_cant_be_deleted".localized
            case .accountSuspended:
                message = "error.user.account_suspended".localized
            case .accountLimitReached:
                message = "error.user.account_limit_reached".localized
            case .unknownError:
                fallthrough
            default:
                message = "error.user.unkown_error".localized
            }
        } else {
            message = error.localizedDescription
        }

        let alert = UIAlertController.alertWithOKButton(message: message, okActionHandler: okHandler)
        present(alert, animated: true)
    }
}
