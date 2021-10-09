
import Foundation
import WireDataModel

final class UserDetailViewControllerFactory: NSObject {

    /// Create a ServiceDetailViewController if the user is a serviceUser, otherwise return a ProfileViewController
    ///
    /// - Parameters:
    ///   - user: user to show the details
    ///   - conversation: conversation currently displaying
    ///   - profileViewControllerDelegate: a ProfileViewControllerDelegate for ProfileViewController
    ///   - viewControllerDismisser: a ViewControllerDismisser for returing UIViewController's dismiss action
    /// - Returns: if the user is a serviceUser, return a ProfileHeaderServiceDetailViewController. if the user not a serviceUser, return a ProfileViewController
    static func createUserDetailViewController(
        user: UserType,
        conversation: ZMConversation,
        profileViewControllerDelegate: ProfileViewControllerDelegate,
        viewControllerDismisser: ViewControllerDismisser
    ) -> UIViewController {
        if user.isServiceUser, let serviceUser = user as? ServiceUser {
            let variant = ServiceDetailVariant(colorScheme: ColorScheme.default.variant, opaque: true)
            let serviceDetailViewController = ServiceDetailViewController(serviceUser: serviceUser, actionType: .removeService(conversation), variant: variant, completion: nil)
            serviceDetailViewController.viewControllerDismisser = viewControllerDismisser
            return serviceDetailViewController
        } else {
            // TODO: Do not present the details if the user is not connected.
            let profileViewController = ProfileViewController(user: user, viewer: SelfUser.current, conversation: conversation)
            profileViewController.delegate = profileViewControllerDelegate
            profileViewController.viewControllerDismisser = viewControllerDismisser
            return profileViewController
        }
    }
}
