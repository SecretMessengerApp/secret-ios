
import Foundation

/**
 * The actions that can be performed from the profile details or devices.
 */

enum ProfileAction: Equatable {
    case createGroup
    case mute(isMuted: Bool)
    case manageNotifications
    case archive
    case deleteContents
    case block(isBlocked: Bool)
    case openOneToOne
    case removeFromGroup
    case connect
    case cancelConnectionRequest
    case openSelfProfile

    /// The text of the button for this action.
    var buttonText: String {
        switch self {
        case .createGroup: return "profile.create_conversation_button_title".localized
        case .mute(let isMuted): return isMuted ? "meta.menu.silence.unmute".localized : "meta.menu.silence.mute".localized
        case .manageNotifications: return "meta.menu.configure_notifications".localized
        case .archive: return "meta.menu.archive".localized
        case .deleteContents: return "meta.menu.clear_content".localized
        case .block(let isBlocked): return isBlocked ? "profile.unblock_button_title".localized : "profile.block_button_title".localized
        case .openOneToOne: return "profile.open_conversation_button_title".localized
        case .removeFromGroup: return "profile.remove_dialog_button_remove".localized
        case .connect: return "profile.connection_request_dialog.button_connect".localized
        case .cancelConnectionRequest: return "meta.menu.cancel_connection_request".localized
        case .openSelfProfile: return "meta.menu.open_self_profile".localized
        }
    }

    /// The icon of the button for this action, if it's eligible to be a key action.
    var keyActionIcon: StyleKitIcon? {
        switch self {
        case .createGroup: return .createConversation
        case .manageNotifications, .mute: return nil
        case .archive: return nil
        case .deleteContents: return nil
        case .block: return nil
        case .openOneToOne: return .conversation
        case .removeFromGroup: return nil
        case .connect: return .plus
        case .cancelConnectionRequest: return .undo
        case .openSelfProfile: return .personalProfile
        }
    }

    /// Whether the action can be used as a key action.
    var isEligibleForKeyAction: Bool {
        return keyActionIcon != nil
    }

}

/**
 * An object that returns the actions that a user can perform in the scope
 * of a conversation.
 */

final class ProfileActionsFactory: NSObject {

    // MARK: - Environmemt

    /// The user that is displayed in the profile details.
    let user: UserType

    /// The user that wants to perform the actions.
    let viewer: UserType

    /// The conversation that the user wants to perform the actions in.
    let conversation: ZMConversation?

    /// The context of the Profile VC
    let context: ProfileViewControllerContext

    // MARK: - Initialization

    /**
     * Creates the action controller with the specified environment.
     * - parameter user: The user that is displayed in the profile details.
     * - parameter viewer: The user that wants to perform the actions.
     * - parameter conversation: The conversation that the user wants to
     * perform the actions in.
     */

    init(user: UserType, viewer: UserType, conversation: ZMConversation?, context: ProfileViewControllerContext) {
        self.user = user
        self.viewer = viewer
        self.conversation = conversation
        self.context = context
    }

    // MARK: - Calculating the Actions

    /**
     * Calculates the list of actions to display to the user.
     */

    func makeActionsList() -> [ProfileAction] {
        // Do nothing if the user was deleted
        if user.isAccountDeleted {
            return []
        }

        // if the user is viewing their own profile, add the open self-profile screen button
        if viewer.isSelfUser && user.isSelfUser {
            return [.openSelfProfile]
        }

        // Do not show any action if the user is blocked
        if user.isBlocked {
            return [.block(isBlocked: true)]
        }

        var conversation: ZMConversation?

        // If there is no conversation and open profile from a conversation, offer to connect to the user if possible
        if let selfConversation = self.conversation {
            conversation = selfConversation
        } else if context == .profileViewer {
            conversation = nil
        } else {
            if !user.isConnected {
                if user.isPendingApprovalByOtherUser {
                    return [.cancelConnectionRequest]
                } else if !user.isPendingApprovalBySelfUser {
                    return [.connect]
                }
            }

            return []
        }

        var actions: [ProfileAction] = []

        switch (context, conversation?.conversationType) {
        case (_, .oneOnOne?):

            if viewer.canCreateConversation {
                actions.append(.createGroup)
            }

            // Notifications, Archive, Delete Contents if available for every 1:1
            if let conversation = conversation {
                let notificationAction: ProfileAction = viewer.isTeamMember ? .manageNotifications : .mute(isMuted: conversation.mutedMessageTypes != .none)
                actions.append(contentsOf: [notificationAction, .archive, .deleteContents])
            }

            // If the viewer is not on the same team as the other user, allow blocking
            if !viewer.canAccessCompanyInformation(of: user) && !user.isWirelessUser {
                actions.append(.block(isBlocked: false))
            }

        case (.profileViewer, .none),
             (_, .group?):
            // Do nothing if the viewer is a wireless user because they can't have 1:1's
            if viewer.isWirelessUser {
                break
            }

            let isOnSameTeam = viewer.canAccessCompanyInformation(of: user)

            // Show connection request actions for unconnected users from different teams.
            if user.isPendingApprovalByOtherUser {
                actions.append(.cancelConnectionRequest)
            } else if user.isConnected || isOnSameTeam {
                actions.append(.openOneToOne)
            } else if user.canBeConnected && !user.isPendingApprovalBySelfUser {
                actions.append(.connect)
            }

            // Only non-guests and non-partners are allowed to remove
            if let conversation = conversation, viewer.canRemoveUser(from: conversation) {
                actions.append(.removeFromGroup)
            }

            // If the user is not from the same team as the other user, allow blocking
            if user.isConnected && !isOnSameTeam && !user.isWirelessUser {
                actions.append(.block(isBlocked: false))
            }

        default:
            break
        }

        return actions
    }

}
