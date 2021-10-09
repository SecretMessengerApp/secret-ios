
protocol ConversationOptionsConfigurable {
    func configure(with conversation: ZMConversation)
}


// a ConversationOptionsCell that with a disclosure indicator on the right
typealias GroupDetailsDisclosureOptionsCell = ConversationOptionsConfigurable & DisclosureCell

class DisclosureCell: RightIconDetailsCell {
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        accessory = StyleKitIcon.disclosureIndicator.makeImage(size: 12, color: sectionTextColor)
    }
}
