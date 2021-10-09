
import UIKit

class GroupDetailsTimeoutOptionsCell: GroupDetailsOptionsCell {

    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.timeoutoptions"
        title = "group_details.timeout_options_cell.title".localized
    }

    override func configure(with conversation: ZMConversation) {
        switch conversation.messageDestructionTimeout {
        case .synced(let value)?:
            status = value.localizedText
        default:
            status = MessageDestructionTimeoutValue.none.localizedText
        }
    }

    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: .like, color: sectionTextColor)
    }

}
