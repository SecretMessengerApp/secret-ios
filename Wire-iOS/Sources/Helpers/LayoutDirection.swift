
import UIKit

extension UIApplication {

    /// Check whether that app is in left to right layout.
    @objc static var isLeftToRightLayout: Bool {
        return UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
    }

}

// MARK: - UIEdgeInsets

extension UIEdgeInsets {

    /// The leading insets, that respect the layout direction.
    var leading: CGFloat {
        if UIApplication.isLeftToRightLayout {
            return left
        } else {
            return right
        }
    }

    /// The trailing insets, that respect the layout direction.
    var trailing: CGFloat {
        if UIApplication.isLeftToRightLayout {
            return right
        } else {
            return left
        }
    }

    /// Returns a copy of the insets that are adapted for the current layout.
    var directionAwareInsets: UIEdgeInsets {
        return UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
    }

}

// MARK: - String

extension String {

    func addingTrailingAttachment(_ attachment: NSTextAttachment, verticalOffset: CGFloat = 0) -> NSAttributedString {
        if let attachmentSize = attachment.image?.size {
            attachment.bounds = CGRect(x: 0, y: verticalOffset, width: attachmentSize.width, height: attachmentSize.height)
        }

        if UIApplication.isLeftToRightLayout {
            return self + "  " + NSAttributedString(attachment: attachment)
        } else {
            return NSAttributedString(attachment: attachment) + "  " + self
        }
    }

    func addingLeadingAttachment(_ attachment: NSTextAttachment, verticalOffset: CGFloat = 0) -> NSAttributedString {
        if let attachmentSize = attachment.image?.size {
            attachment.bounds = CGRect(x: 0, y: verticalOffset, width: attachmentSize.width, height: attachmentSize.height)
        }
        
        if UIApplication.isLeftToRightLayout {
            return NSAttributedString(attachment: attachment) + "  " + self
        } else {
            return self + "  " + NSAttributedString(attachment: attachment)
        }
    }

}
