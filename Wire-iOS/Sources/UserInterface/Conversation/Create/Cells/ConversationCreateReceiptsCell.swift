
import Foundation

class ConversationCreateReceiptsCell: IconToggleCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "toggle.newgroup.allowreceipts"
        title = "conversation.create.receipts.title".localized
        showSeparator = false
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let color = UIColor.dynamic(scheme: .title)
        icon = StyleKitIcon.eye.makeImage(size: .tiny, color: color)
    }
}

extension ConversationCreateReceiptsCell: ConversationCreationValuesConfigurable {
    func configure(with values: ConversationCreationValues) {
        isOn = values.enableReceipts
    }
}
