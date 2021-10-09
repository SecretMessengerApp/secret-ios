
import Foundation

class ConversationCreateGuestsCell: IconToggleCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "toggle.newgroup.allowguests"
        title = "conversation.create.guests.title".localized
        showSeparator = false
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let color = UIColor.dynamic(scheme: .title)
        icon = StyleKitIcon.guest.makeImage(size: .tiny, color: color)
    }
}

extension ConversationCreateGuestsCell: ConversationCreationValuesConfigurable {
    func configure(with values: ConversationCreationValues) {
        isOn = values.allowGuests
    }
}
