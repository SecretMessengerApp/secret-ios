//
import UIKit

extension UILabel {
    convenience init(
        key: String? = nil,
        size: FontSize = .normal,
        weight: FontWeight = .regular,
        color: ColorSchemeColor,
        variant: ColorSchemeVariant = ColorScheme.default.variant
        ) {
        self.init(frame: .zero)
        text = key.map { $0.localized }
        font = FontSpec(size, weight).font
        textColor = UIColor.from(scheme: color, variant: variant)
    }
}
