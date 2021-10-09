

import Foundation

public class GuestIndicator: UIImageView, Themeable {
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        setIcon(.guest, size: .tiny, color: UIColor.from(scheme: .iconGuest, variant: colorSchemeVariant))
    }
    
    init() {
        super.init(frame: .zero)
        contentMode = .scaleToFill
        setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        accessibilityIdentifier = "img.guest"
        applyColorScheme(colorSchemeVariant)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class GuestLabelIndicator: UIStackView, Themeable {
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorSchemeOnSubviews(colorSchemeVariant)
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        label.textColor = UIColor.dynamic(scheme: .title)
        guestIcon.setIcon(.guest, size: .tiny, color: UIColor.dynamic(scheme: .title))
    }
    
    private let guestIcon = UIImageView()
    private let label = UILabel()
    
    init() {
        guestIcon.contentMode = .scaleToFill
        guestIcon.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        guestIcon.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        guestIcon.setContentHuggingPriority(UILayoutPriority.required, for: .vertical)
        guestIcon.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        guestIcon.setIcon(.guest, size: .tiny, color: UIColor.dynamic(scheme: .title))
        guestIcon.accessibilityIdentifier = "img.guest"

        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = FontSpec(.medium, .light).font
        label.textColor = UIColor.dynamic(scheme: .title)
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        label.text = "profile.details.guest".localized
        
        super.init(frame: .zero)

        axis = .horizontal
        spacing = 8
        distribution = .fill
        alignment = .fill
        addArrangedSubview(guestIcon)
        addArrangedSubview(label)
        
        accessibilityIdentifier = "guest indicator"
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
