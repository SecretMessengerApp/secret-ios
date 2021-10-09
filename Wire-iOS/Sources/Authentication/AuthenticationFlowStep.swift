
import Foundation

/**
 * The type of credentials to ask when the user is creating or
 * providing credentials.
 */

enum AuthenticationCredentialsType {
    /// Register by phone.
    case phone

    /// Register by email.
    case email
}

/**
 * The context that caused the user to not have a complete history.
 */

enum NoHistoryContext {
    /// The user signed into this device for the first time.
    case newDevice

    /// The user logged out.
    case loggedOut
}

/**
 * Steps of the authentication flow.
 */

indirect enum AuthenticationFlowStep: Equatable {

    // Initial Steps
    case start
    case landingScreen
    case reauthenticate(credentials: LoginCredentials?, numberOfAccounts: Int, isSignedOut: Bool)

    // Sign-In
    case provideCredentials(AuthenticationCredentialsType, AuthenticationPrefilledCredentials?)
    case sendLoginCode(phoneNumber: String, isResend: Bool)
    case enterLoginCode(phoneNumber: String)
    case authenticateEmailCredentials(ZMEmailCredentials)
    case authenticatePhoneCredentials(ZMPhoneCredentials)
    case companyLogin

    // Post Sign-In
    case noHistory(credentials: ZMCredentials?, context: NoHistoryContext)
    case clientManagement(clients: [UserClient], credentials: ZMCredentials?)
    case deleteClient(clients: [UserClient], credentials: ZMCredentials?)
    case addEmailAndPassword
    case registerEmailCredentials(ZMEmailCredentials, isResend: Bool)
    case pendingEmailLinkVerification(ZMEmailCredentials)
    case pendingInitialSync(next: AuthenticationFlowStep?)

    // Registration
    case teamCreation(TeamCreationState)
    case createCredentials(UnregisteredUser, AuthenticationCredentialsType)
    case sendActivationCode(UnverifiedCredentials, user: UnregisteredUser, isResend: Bool)
    case enterActivationCode(UnverifiedCredentials, user: UnregisteredUser)
    case activateCredentials(UnverifiedCredentials, user: UnregisteredUser, code: String)
    case incrementalUserCreation(UnregisteredUser, IntermediateRegistrationStep)
    case createUser(UnregisteredUser)

    // MARK: - Properties

    /// Whether the step can be unwinded.
    var allowsUnwind: Bool {
        switch self {
        case .landingScreen: return false
        case .clientManagement: return false
        case .noHistory: return false
        case .addEmailAndPassword: return false
        case .incrementalUserCreation: return false
        case .teamCreation(let teamState): return teamState.allowsUnwind
        default: return true
        }
    }

    /// Whether the authentication steps generates a user interface.
    var needsInterface: Bool {
        switch self {
        // Initial Steps
        case .start: return false
        case .landingScreen: return true
        case .reauthenticate: return true

        // Sign-In
        case .provideCredentials: return true
        case .sendLoginCode: return false
        case .enterLoginCode: return true
        case .authenticateEmailCredentials: return false
        case .authenticatePhoneCredentials: return false
        case .registerEmailCredentials: return false
        case .companyLogin: return false

        // Post Sign-In
        case .noHistory: return true
        case .clientManagement: return true
        case .deleteClient: return true
        case .addEmailAndPassword: return true
        case .pendingInitialSync: return true
        case .pendingEmailLinkVerification: return true

        // Registration
        case .teamCreation(let teamState): return teamState.needsInterface
        case .createCredentials: return true
        case .sendActivationCode: return false
        case .enterActivationCode: return true
        case .activateCredentials: return false
        case .incrementalUserCreation(_, let intermediateStep): return intermediateStep.needsInterface
        case .createUser: return false
        }
    }

}

// MARK: - Intermediate Steps

/**
 * Intermediate steps required for user registration.
 */

enum IntermediateRegistrationStep: Equatable {
    case start, provideMarketingConsent, setName, setPassword

    var needsInterface: Bool {
        switch self {
        case .start: return false
        case .provideMarketingConsent: return false
        default : return true
        }
    }
}
