
import UIKit


class GroupDetailsGuestOptionsCell: GroupDetailsDisclosureOptionsCell {

    var isOn = false {
        didSet {
            let key = "group_details.guest_options_cell.\(isOn ? "enabled" : "disabled")"
            status = key.localized
        }
    }

    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.guestoptions"
        title = "group_details.guest_options_cell.title".localized
    }

    func configure(with conversation: ZMConversation) {
        self.isOn = conversation.allowGuests
    }

    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)

        icon = StyleKitIcon.guest.makeImage(size: .tiny,
                                            color: UIColor.dynamic(scheme: .title))
    }

}
