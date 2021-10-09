
import Foundation

/**
 * Provides and asks for context when registering users.
 */

protocol AuthenticationCoordinatorDelegate: AuthenticationStatusProvider {

    /**
     * The coordinator finished authenticating the user.
     * - parameter addedAccount: Whether the authentication action added a new account
     * to this device.
     */

    func userAuthenticationDidComplete(addedAccount: Bool)

}
