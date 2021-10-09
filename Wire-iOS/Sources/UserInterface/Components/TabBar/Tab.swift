
import UIKit
import Cartography

class Tab: Button {

    var title: String = "" {
        didSet {
            accessibilityLabel = title
            setTitle(title.localizedUppercase, for: .normal)
        }
    }

    var colorSchemeVariant : ColorSchemeVariant {
        didSet {
            updateColors()
        }
    }

    init(variant: ColorSchemeVariant) {
        colorSchemeVariant = variant
        super.init()

        titleLabel?.font = FontSpec(.small, .semibold).font
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        isSelected = false
        
        updateColors()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 48)
    }
    
    private func updateColors() {
        setTitleColor(.dynamic(scheme: .tabNormal), for: .normal)
        setTitleColor(.dynamic(scheme: .tabSelected), for: .selected)
        setTitleColor(.dynamic(scheme: .tabHighlighted), for: .highlighted)
    }
}
