
import Foundation

extension CGFloat {
    enum StartUI {
        static public let CellHeight: CGFloat = 56
    }
    
    enum SplitView {
        static public let LeftViewWidth: CGFloat = 336

        /// on iPad 9.7 inch 2/3 mode, right view's width is  396pt, use the compact mode's narrower margin
        /// when the window is small then or equal to (396 + LeftViewWidth = 732), use compact mode margin
        static public let IPadMarginLimit: CGFloat = 732
    }

    enum ConversationList {
        static let horizontalMargin: CGFloat = 16
    }

    enum ConversationListHeader {
        static let iconWidth: CGFloat = 32
        /// 75% of ConversationAvatarView.iconWidth + TeamAccountView.imageInset * 2 = 24 + 2 * 2
        static let avatarSize: CGFloat = 28

        static let barHeight: CGFloat = 44
    }
    
    enum ConversationListSectionHeader {
        static let height: CGFloat = 51
    }

    enum ConversationAvatarView {
        static let iconSize: CGFloat = 60
    }

    enum AccountView {
        static let iconWidth: CGFloat = 32
    }

    enum TeamAccountView {
        static let imageInset: CGFloat = 2
    }
}

