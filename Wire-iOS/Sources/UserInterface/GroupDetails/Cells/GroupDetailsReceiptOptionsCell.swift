
import UIKit


final class GroupDetailsReceiptOptionsCell: IconToggleCell {

    override func setUp() {
        super.setUp()

        accessibilityIdentifier = "cell.groupdetails.receiptoptions"
        toggle.accessibilityIdentifier = "ReadReceiptsSwitch"

        title = "group_details.receipt_options_cell.title".localized
    }

    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        
        icon = StyleKitIcon.eye.makeImage(
            size: .tiny,
            color: UIColor.dynamic(scheme: .title)
        )
    }
}

extension GroupDetailsReceiptOptionsCell: ConversationOptionsConfigurable {
    func configure(with conversation: ZMConversation) {
         isOn = conversation.hasReadReceiptsEnabled
    }
}
