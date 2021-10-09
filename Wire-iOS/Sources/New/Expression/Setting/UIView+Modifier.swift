
import UIKit

extension UIStackView {
    static var horizontal: UIStackView {
        let v = UIStackView()
        v.axis = .horizontal
        return v
    }
    
    static var vertical: UIStackView {
        let v = UIStackView()
        v.axis = .vertical
        return v
    }
    
    func space(_ value: CGFloat) -> Self {
        self.spacing = value
        return self
    }
    
    func addFlexiableItem() {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentHuggingPriority(.defaultLow, for: .vertical)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        self.addArrangedSubview(v)
    }
}

extension UIButton {
    @discardableResult func font(size: CGFloat, weight: UIFont.Weight = .regular) -> Self {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        self.titleLabel?.font = font
        return self
    }
    
    @discardableResult func color(_ value: UIColor) -> Self {
        self.setTitleColor(value, for: .normal)
        return self
    }
    
    @discardableResult func color(_ value: String) -> Self {
        self.setTitleColor(UIColor(hex: value), for: .normal)
        return self
    }
}

extension UILabel {
    @discardableResult func font(size: CGFloat, weight: UIFont.Weight = .regular) -> Self {
        let font = UIFont.systemFont(ofSize: size, weight: weight)
        self.font = font
        return self
    }
    
    @discardableResult func color(_ value: UIColor) -> Self {
        self.textColor = value
        return self
    }
    
    @discardableResult func color(_ value: String) -> Self {
        self.textColor = UIColor(hex: value)
        return self
    }
    
    @discardableResult func lines(_ value: Int = 1) -> Self {
        self.numberOfLines = value
        return self
    }
    
    @discardableResult func align(_ value: NSTextAlignment) -> Self {
        self.textAlignment = value
        return self
    }
}

extension UIView {
    @discardableResult func background(_ value: UIColor) -> Self {
        self.backgroundColor = value
        return self
    }
    
    @discardableResult func background(_ value: String) -> Self {
        self.backgroundColor = UIColor(hex: value)
        return self
    }
    
    @discardableResult func corner(radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        return self
    }
}

extension UIView {
    // motion effect
    func applyMotion(amount: CGFloat = 20) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]

        self.addMotionEffect(group)
    }
}
