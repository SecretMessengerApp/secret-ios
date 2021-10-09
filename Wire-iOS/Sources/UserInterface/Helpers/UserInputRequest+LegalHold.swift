
import UIKit
import WireCryptobox

extension UserType where Self: SelfLegalHoldSubject {

    /**
     * Creates the password input request to respond to a legal hold activation request from the team admin.
     * - parameter request: The legal hold request that the user received.
     * - parameter cancellationHandler: The block to execute when the user ignores the legal hold request.
     * - parameter inputHandler: The block to execute with the password of the user.
     * - note: If the user dismisses the alert, we will make the legal hold request as acknowledged.
     */

    func makeLegalHoldInputRequest(for request: LegalHoldRequest, cancellationHandler: @escaping () -> Void, inputHandler: @escaping (String?) -> Void) -> UserInputRequest {
        let fingerprintString = EncryptionSessionsDirectory.fingerprint(fromPrekey: request.lastPrekey.key)?.fingerprintString ?? "<fingerprint unavailable>"
        var legalHoldMessage = "legalhold_request.alert.detail".localized(args: fingerprintString)

        var inputConfiguration: UserInputRequest.InputConfiguration? = nil

        if !usesCompanyLogin {
            inputConfiguration = UserInputRequest.InputConfiguration(
                placeholder: "password.placeholder".localized,
                prefilledText: nil,
                isSecure: true,
                textContentType: .passwordIfAvailable,
                accessibilityIdentifier: "legalhold-request-password-input",
                validator: { !$0.isEmpty }
            )

            legalHoldMessage += "\n"
            legalHoldMessage += "legalhold_request.alert.detail.enter_password".localized
        }

        return UserInputRequest(
            title: "legalhold_request.alert.title".localized,
            message: legalHoldMessage,
            continueActionTitle: "general.accept".localized,
            cancelActionTitle: "general.skip".localized,
            inputConfiguration: inputConfiguration,
            completionHandler: inputHandler,
            cancellationHandler: cancellationHandler
        )
    }

}

