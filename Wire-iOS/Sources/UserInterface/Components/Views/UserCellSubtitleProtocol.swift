
import Foundation

protocol UserCellSubtitleProtocol: class {
    func subtitle(forRegularUser user: UserType?) -> NSAttributedString?

    static var correlationFormatters:  [ColorSchemeVariant : AddressBookCorrelationFormatter] { get set }

    static var boldFont: UIFont { get }
    static var lightFont: UIFont { get }
}

extension UserCellSubtitleProtocol where Self: UIView & Themeable {
    func subtitle(forRegularUser user: UserType?) -> NSAttributedString? {
        guard let user = user else { return nil }

        var components: [NSAttributedString?] = []

        if let handle = user.handle, !handle.isEmpty {
            components.append("@\(handle)" && UserCell.boldFont)
        }

        WirelessExpirationTimeFormatter.shared.string(for: user).apply {
            components.append($0 && UserCell.boldFont)
        }

        if let user = user as? ZMUser, let addressBookName = user.addressBookEntry?.cachedName {
            let formatter = Self.correlationFormatter(for: colorSchemeVariant)
            components.append(formatter.correlationText(for: user, addressBookName: addressBookName))
        }

        return components.compactMap({ $0 }).joined(separator: " " + String.MessageToolbox.middleDot + " " && UserCell.lightFont)
    }

    private static func correlationFormatter(for colorSchemeVariant: ColorSchemeVariant) -> AddressBookCorrelationFormatter {
        if let formatter = correlationFormatters[colorSchemeVariant] {
            return formatter
        }

        let color = UIColor.dynamic(scheme: .subtitle)
        let formatter = AddressBookCorrelationFormatter(lightFont: lightFont, boldFont: boldFont, color: color)

        correlationFormatters[colorSchemeVariant] = formatter

        return formatter
    }

}
