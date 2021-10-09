
final class AvailabilityStringBuilder: NSObject {

    static func string(for user: ZMUser, with style: AvailabilityLabelStyle, color: UIColor? = nil) -> NSAttributedString? {
        
        var title: String = ""
        var color = color
        let availability = user.availability
        var fontSize: FontSize = .small
        
        switch style {
            case .list: do {
                if let name = user.name {
                    title = name
                }

                fontSize = .normal
                if color == nil {
                    color = UIColor.from(scheme: .textForeground, variant: .dark)
                }
            }
            case .participants: do {
                title = user.displayName.localizedUppercase
                color = UIColor.dynamic(scheme: .title)
            }
            case .placeholder: do {
                if availability != .none { //Should use the default placeholder string
                    title = "availability.\(availability.canonicalName).placeholder".localized(args: user.displayName).localizedUppercase
                }
            }
        }
        
        guard let textColor = color else { return nil }
        let icon = AvailabilityStringBuilder.icon(for: availability, with: textColor, and: fontSize)
        let attributedText = IconStringsBuilder.iconString(with: icon, title: title, interactive: false, color: textColor)
        return attributedText
    }
    
    static func icon(for availability: Availability, with color: UIColor, and size: FontSize) -> NSTextAttachment? {
        guard availability != .none, let iconType = availability.iconType
            else { return nil }
        
        let verticalCorrection: CGFloat
        
        switch size {
        case .small:
            verticalCorrection = -1
        case .medium, .large, .normal:
            verticalCorrection = 0
        }
        
        return NSTextAttachment.textAttachment(for: iconType, with: color, iconSize: 10, verticalCorrection: verticalCorrection)
    }
}
