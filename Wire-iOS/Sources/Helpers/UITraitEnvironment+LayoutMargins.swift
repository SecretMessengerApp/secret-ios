
import Foundation

struct HorizontalMargins {
    var left: CGFloat
    var right: CGFloat

    init(left: CGFloat, right: CGFloat) {
        self.left = left
        self.right = right
    }

    init(userInterfaceSizeClass: UIUserInterfaceSizeClass) {
        switch userInterfaceSizeClass {
        case .regular:
            left = 96
            right = 96
        default:
            left = 56
            right = 16
        }
    }
}

extension UITraitEnvironment {
    var conversationHorizontalMargins: HorizontalMargins {
        return conversationHorizontalMargins()
    }

    func conversationHorizontalMargins(windowWidth: CGFloat? = UIApplication.shared.keyWindow?.frame.width) -> HorizontalMargins {
        guard traitCollection.horizontalSizeClass == .regular else {
            return HorizontalMargins(userInterfaceSizeClass: .compact)
        }

        let userInterfaceSizeClass: UIUserInterfaceSizeClass

        /// on iPad 9.7 inch 2/3 mode, right view's width is  396pt, use the compact mode's narrower margin
        if let windowWidth = windowWidth,
            windowWidth <= CGFloat.SplitView.IPadMarginLimit {
            userInterfaceSizeClass = .compact
        } else {
            userInterfaceSizeClass = .regular
        }

        return HorizontalMargins(userInterfaceSizeClass: userInterfaceSizeClass)
    }

    var directionAwareConversationLayoutMargins: HorizontalMargins {
        let margins = conversationHorizontalMargins

        if UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft {
            return HorizontalMargins(left: margins.right, right: margins.left)
        } else {
            return margins
        }
    }
}
