
import UIKit

extension AuthenticationCoordinator: TeamMemberInviteViewControllerDelegate {

    func teamInviteViewControllerDidFinish(_ controller: TeamMemberInviteViewController) {
        delegate?.userAuthenticationDidComplete(addedAccount: true)
    }

}
