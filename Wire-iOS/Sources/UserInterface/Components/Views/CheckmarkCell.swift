
import UIKit

final class CheckmarkCell: RightIconDetailsCell {

    var showCheckmark: Bool = false {
        didSet {
            updateCheckmark(forColor: ColorScheme.default.variant)

            titleBolded = showCheckmark
        }
    }

    override var disabled: Bool {
        didSet {
            updateCheckmark(forColor: ColorScheme.default.variant)
        }
    }
    
    override func setUp() {
        super.setUp()
        icon = nil
        status = nil

        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true
    }

    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        updateCheckmark(forColor: colorSchemeVariant)
    }

    private func updateCheckmark(forColor colorSchemeVariant: ColorSchemeVariant) {

        guard showCheckmark else {
            accessory = nil
            return
        }

        let color: UIColor
        
        switch (colorSchemeVariant, disabled) {
        case (.light, false):
            color = UIColor.dynamic(scheme: .title)
        case (.light, true):
            color = UIColor.from(scheme: .textPlaceholder, variant: colorSchemeVariant)
        case (.dark, false):
            color = .white
        case (.dark, true):
            color = UIColor.from(scheme: .textPlaceholder, variant: colorSchemeVariant)
        }
        accessory = StyleKitIcon.checkmark.makeImage(size: .tiny, color: color)
    }

    // MARK: - accessibility
    override var accessibilityLabel: String? {
        get {
            return title
        }

        set {
            //no op
        }
    }

    override var accessibilityValue: String? {
        get {
            return "\(showCheckmark)"
        }

        set {
            //no op
        }
    }
}
