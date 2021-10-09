
import Foundation

/**
 * The state of team creation. To advance to the next step, you need to provide the String
 * input from the user.
 */

enum TeamCreationState: Equatable {
    case setTeamName
    case setEmail(teamName: String)
    case sendEmailCode(teamName: String, email: String, isResend: Bool)
    case verifyEmail(teamName: String, email: String)
    case verifyActivationCode(teamName: String, email: String, activationCode: String)
    case provideMarketingConsent(teamName: String, email: String, activationCode: String)
    case setFullName(teamName: String, email: String, activationCode: String, marketingConsent: Bool)
    case setPassword(teamName: String, email: String, activationCode: String, marketingConsent: Bool, fullName: String)
    case createTeam(teamName: String, email: String, activationCode: String, marketingConsent: Bool, fullName: String, password: String)
    case inviteMembers

    /// Whether the step needs an interface.
    var needsInterface: Bool {
        switch self {
        case .sendEmailCode, .verifyActivationCode: return false
        case .provideMarketingConsent: return false
        case .createTeam: return false
        default: return true
        }
    }

    /// Whether it's possible to exit this step and .
    var allowsUnwind: Bool {
        switch self {
        case .setFullName: return false
        case .inviteMembers: return false
        default: return true
        }
    }
}

// MARK: - State transitions

extension TeamCreationState {

    /**
     * Advances to the next possible state with the given user input.
     * - parameter value: The value provided by the user.
     */

    func nextState(with value: String) -> TeamCreationState? {
        switch self {
        case .setTeamName:
            return .setEmail(teamName: value)
        case let .setEmail(teamName: teamName):
            return .sendEmailCode(teamName: teamName, email: value, isResend: false)
        case .sendEmailCode:
            return nil // transition handled by the responder chain
        case let .verifyEmail(teamName: teamName, email: email):
            return .verifyActivationCode(teamName: teamName, email: email, activationCode: value)
        case let .verifyActivationCode(teamName, email, activationCode):
            return .provideMarketingConsent(teamName: teamName, email: email, activationCode: activationCode)
        case .provideMarketingConsent:
            return nil // handled by the authentication coordinator via actions
        case let .setFullName(teamName: teamName, email: email, activationCode: activationCode, marketingConsent: marketingConsent):
            return .setPassword(teamName: teamName, email: email, activationCode: activationCode, marketingConsent: marketingConsent, fullName: value)
        case let .setPassword(teamName: teamName, email: email, activationCode: activationCode, marketingConsent: marketingConsent, fullName: fullName):
            return .createTeam(teamName: teamName, email: email, activationCode: activationCode, marketingConsent: marketingConsent, fullName: fullName, password: value)
        case .createTeam:
            return nil // transition handled by the responder chain
        case .inviteMembers:
            return nil // last step
        }
    }

}
