
import Foundation
import UIKit

final class InviteButton: IconButton {
    
    init(variant: ColorSchemeVariant = ColorScheme.default.variant) {
        super.init()
        setTitleColor(.dynamic(scheme: .title), for: .normal)
        adjustsTitleWhenHighlighted = true
        setBackgroundImageColor(.init(red: 0.612, green: 0.655, blue: 0.686, alpha: 0.2), for: .normal)
        clipsToBounds = true
        titleLabel?.font = FontSpec(.normal, .semibold).font
        
        contentEdgeInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        layer.cornerRadius = 4
    }
}
