

import Foundation
import MessageUI


class EmailInvitePresenter: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    static let sharedInstance: EmailInvitePresenter = EmailInvitePresenter()
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: .none)
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: .none)
    }
}


extension ZMAddressBookContact {

    static func canInviteLocallyWithEmail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func inviteLocallyWithEmail(_ email: String) {
        let composeController = MFMailComposeViewController()
        composeController.mailComposeDelegate = EmailInvitePresenter.sharedInstance
        composeController.modalPresentationStyle = .formSheet

        composeController.setMessageBody(invitationBody(), isHTML: false)
        composeController.setToRecipients([email])
        ZClientViewController.shared?.present(composeController, animated: true, completion: .none)
    }
    
    static func canInviteLocallyWithPhoneNumber() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    func inviteLocallyWithPhoneNumber(_ phoneNumber: String) {
        let composeController = MFMessageComposeViewController()
        composeController.messageComposeDelegate = EmailInvitePresenter.sharedInstance
        composeController.modalPresentationStyle = .formSheet
        composeController.body = invitationBody()
        composeController.recipients = [phoneNumber]
        ZClientViewController.shared?.present(composeController, animated: true, completion: .none)
    }

    private func invitationBody() -> String {
        guard
            let handle = SelfUser.provider?.selfUser.handle
        else {
            return "send_invitation_no_email.text".localized
        }

        return "send_invitation.text".localized(args: "@" + handle)
    }
}
