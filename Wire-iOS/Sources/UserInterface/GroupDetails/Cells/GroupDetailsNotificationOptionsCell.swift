//
import Foundation

class GroupDetailsNotificationOptionsCell: GroupDetailsDisclosureOptionsCell {
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.notificationsoptions"
        title = "Notifications"
    }
    
    func configure(with conversation: ZMConversation) {
        guard let key = conversation.mutedMessageTypes.localizationKey else {
            return assertionFailure("Invalid muted message type.")
        }
        
        self.status = key.localized
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        
        icon = StyleKitIcon.alerts.makeImage(size: .tiny,
                       color: UIColor.dynamic(scheme: .title))
    }

}
