
import Foundation

extension NSTextAttachment {
    static func textAttachment(for icon: StyleKitIcon, with color: UIColor, iconSize: StyleKitIcon.Size = 10, verticalCorrection: CGFloat = 0) -> NSTextAttachment {
        let image = icon.makeImage(size: iconSize, color: color)
        let attachment = NSTextAttachment()
        attachment.image = image.withColor(color)
        let ratio = image.size.width / image.size.height
        attachment.bounds = CGRect(x: 0, y: verticalCorrection, width: iconSize.rawValue * ratio, height: iconSize.rawValue)
        return attachment
    }
}
