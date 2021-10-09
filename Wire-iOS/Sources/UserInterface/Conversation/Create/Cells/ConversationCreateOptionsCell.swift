

class ConversationCreateOptionsCell: RightIconDetailsCell {
    
    var expanded = false {
        didSet { applyColorScheme(colorSchemeVariant) }
    }
    
    override func setUp() {
        super.setUp()
        accessibilityIdentifier = "cell.groupdetails.options"
        title = "conversation.create.options.title".localized
        icon = nil
        showSeparator = false
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        backgroundColor = .from(scheme: .sectionBackgroundHighlighted, variant: colorSchemeVariant)
        
        let color = UIColor.dynamic(scheme: .subtitle)
        let image = StyleKitIcon.downArrow.makeImage(size: .tiny, color: color)
        
        
        // flip upside down if necessary
        if let cgImage = image.cgImage, expanded {
            accessory = UIImage(cgImage: cgImage, scale: image.scale, orientation: .downMirrored)
        } else {
            accessory = StyleKitIcon.downArrow.makeImage(size: .tiny, color: color)
        }
    }
}

extension ConversationCreateOptionsCell: ConversationCreationValuesConfigurable {
    func configure(with values: ConversationCreationValues) {
        let guests = values.allowGuests.localized.localizedUppercase
        let receipts = values.enableReceipts.localized.localizedUppercase
        status = "conversation.create.options.subtitle".localized(args: guests, receipts)
    }
}

private extension Bool {
    var localized: String {
        return self ? "general.on".localized : "general.off".localized
    }
}
