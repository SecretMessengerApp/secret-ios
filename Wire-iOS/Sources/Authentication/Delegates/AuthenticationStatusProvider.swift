
import Foundation

/**
 * Provides context about the current authentication stack.
 */

protocol AuthenticationStatusProvider: class {

    /**
     * Whether the authenticated user was registered on this device.
     *
     * - returns: `true` if the user was registered on this device, `false` otherwise.
     */

    var authenticatedUserWasRegisteredOnThisDevice: Bool { get }

    /**
     * Whether the authenticated user needs an e-mail address to register their client.
     *
     * - returns: `true` if the user needs to add an e-mail, `false` otherwise.
     */

    var authenticatedUserNeedsEmailCredentials: Bool { get }

    /**
     * The authentication coordinator requested the shared user session.
     * - returns: The shared user session, if any.
     */

    var sharedUserSession: ZMUserSession? { get }

    /**
     * The authentication coordinator requested the shared user profile.
     * - returns: The shared user profile, if any.
     */

    var selfUserProfile: UserProfileUpdateStatus? { get }

    /**
     * The authentication coordinator requested the shared user.
     * - returns: The shared user, if any.
     */

    var selfUser: ZMUser? { get }

    /**
     * The authentication coordinator requested the number of accounts.
     * - returns: The number of currently logged in accounts.
     */

    var numberOfAccounts: Int { get }

}
