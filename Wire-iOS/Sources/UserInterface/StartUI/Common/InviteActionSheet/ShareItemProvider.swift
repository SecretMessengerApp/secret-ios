
import UIKit

final class ShareItemProvider: UIActivityItemProvider {
    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "send_invitation.subject".localized
    }

    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard
            let handle = SelfUser.provider?.selfUser.handle
        else {
            return "send_invitation_no_email.text".localized
        }

        let displayHandle = "@\(handle)"
        return String(format: "send_invitation.text".localized, displayHandle)
    }
}
