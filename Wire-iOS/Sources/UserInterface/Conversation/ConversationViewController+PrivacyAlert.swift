
import UIKit

extension ConversationViewController {

    private enum PrivacyAlertAction {
        case verifyDevices
        case sendAnyway
        case legalHoldDetails
        case cancel

        var localizedTitle: String {
            switch self {
            case .verifyDevices:
                return "meta.degraded.verify_devices_button".localized
            case .sendAnyway:
                return "meta.degraded.send_anyway_button".localized
            case .legalHoldDetails:
                return "meta.legalhold.info_button".localized
            case .cancel:
                return "general.cancel".localized
            }
        }

        var preferredStyle: UIAlertAction.Style {
            switch self {
            case .cancel:
                return .cancel
            default:
                return .default
            }
        }
    }

    // MARK: - Alert

    /// Presents an alert in response to a change in privacy (legal hold and/or client verification).
    @objc(presentPrivacyWarningAlertForChange:)
    func presentPrivacyWarningAlert(for changeInfo: ConversationChangeInfo) {
        let title: String
        let message = "meta.degraded.dialog_message".localized
        var actions: [PrivacyAlertAction] = []

        if conversation.legalHoldStatus == .pendingApproval {
            title = "meta.legalhold.send_alert_title".localized
            actions.append(.legalHoldDetails)

            if conversation.securityLevel == .secureWithIgnored {
                actions.append(.verifyDevices)
            }

            actions += [.sendAnyway, .cancel]
        } else if conversation.securityLevel == .secureWithIgnored {
            let users = changeInfo.usersThatCausedConversationToDegrade
            let names = changeInfo.usersThatCausedConversationToDegrade.map { $0.displayName }.joined(separator: ", ")
            let keySuffix = users.count <= 1 ? "singular" : "plural"
            title = "meta.degraded.degradation_reason_message.\(keySuffix)".localized(args: names)
            
            actions += [.verifyDevices, .sendAnyway, .cancel]
        } else {
            // no-op: there is no privacy warning
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for action in actions {
            let alertAction = UIAlertAction(title: action.localizedTitle, style: action.preferredStyle) { [weak self] _ in
                self?.performPrivacyAction(action)
            }

            alert.addAction(alertAction)
        }

        present(alert, animated: true)
    }

    // MARK: - Handling the Result

    private func performPrivacyAction(_ action: PrivacyAlertAction) {
        switch action {
        case .verifyDevices:
            conversation.acknowledgePrivacyWarning(withResendIntent: false)
            presentVerificationScreen()
        case .legalHoldDetails:
            conversation.acknowledgePrivacyWarning(withResendIntent: false)
            presentLegalHoldDetails()
        case .sendAnyway:
            conversation.acknowledgePrivacyWarning(withResendIntent: true)
        case .cancel:
            conversation.acknowledgePrivacyWarning(withResendIntent: false)
        }
    }

    private func presentVerificationScreen() {
        guard let selfUser = ZMUser.selfUser() else { return }

        if selfUser.hasUntrustedClients {
            ZClientViewController.shared?.openClientListScreen(for: selfUser)
        } else if let connectedUser = conversation.connectedUser, conversation.conversationType == .oneOnOne {
            let profileViewController = ProfileViewController(user: connectedUser, viewer: selfUser, conversation: conversation, context: .deviceList)
            profileViewController.delegate = self
            profileViewController.viewControllerDismisser = self
            let navigationController = profileViewController.wrapInNavigationController()
            navigationController.modalPresentationStyle = .formSheet
            present(navigationController, animated: true)
        } else if conversation.conversationType == .group {
            let participants = conversation.sortedOtherParticipants
            let participantsViewController = GroupParticipantsDetailViewController(participants: participants, selectedParticipants: [], conversation: conversation)
            let navigationController = participantsViewController.wrapInNavigationController()
            navigationController.modalPresentationStyle = .formSheet
            present(navigationController, animated: true)
        }
    }

    private func presentLegalHoldDetails() {
        LegalHoldDetailsViewController.present(in: self, conversation: conversation)
    }

}
