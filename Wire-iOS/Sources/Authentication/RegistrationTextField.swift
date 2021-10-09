

import UIKit

final class RegistrationTextField: UITextField {

    enum RightAccessoryView {
        case none, confirmButton, guidanceDot, custom
    }
    
    enum LeftAccessoryView {
        case none, countryCode
    }
        
    var customRightView: UIView?
    
    var placeholderInsets: UIEdgeInsets = .zero
    var textInsets: UIEdgeInsets = .zero
    
    let confirmButton = IconButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConfirmButton()
        textColor = .dynamic(scheme: .title)
        tintColor = .dynamic(scheme: .title)
        textInsets = .init(top: 0, left: 16, bottom: 0, right: 8)
        placeholderInsets = .init(top: 0, left: 8, bottom: 0, right: 8)
        autocorrectionType = .no
        contentVerticalAlignment = .center
        layer.cornerRadius = 20
        layer.masksToBounds = true
        layer.borderWidth = .hairline
        layer.borderColor = UIColor.dynamic(scheme: .separator).cgColor
        backgroundColor = .dynamic(scheme: .secondaryBackground)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let confirmButtonWidth: CGFloat = 40
    private let countryCodeViewWidth: CGFloat = 60
    private let guidanceDotViewWidth: CGFloat = 40
    
    private func setupConfirmButton() {
        confirmButton.setIconColor(scheme: .iconNormal, for: .normal)
        confirmButton.accessibilityIdentifier = "confirm button"
    }
    
    override var placeholder: String? {
        didSet {
            attributedPlaceholder = (placeholder ?? "") && [
                .font: UIFont.smallFont
            ]
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            textColor = .dynamic(scheme: isEnabled ? .title : .disable)
        }
    }
    
    var rightAccessoryView: RightAccessoryView = .none {
        didSet {
            switch rightAccessoryView {
            case .none:
                rightView = nil
                rightViewMode = .never
            case .confirmButton:
                rightView = confirmButton
                rightViewMode = .always
            case .guidanceDot:
                rightViewMode = .always
            case .custom:
                rightView = customRightView
                rightViewMode = .always
            }
        }
    }
    
    var leftAccessoryView: LeftAccessoryView = .none {
        didSet {
            switch leftAccessoryView {
            case .none:
                leftView = nil
                leftViewMode = .never
            case .countryCode:
                leftViewMode = .always
            }
        }
    }
    
    override func drawPlaceholder(in rect: CGRect) {
        super.drawPlaceholder(in: rect.inset(by: placeholderInsets))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds.inset(by: textInsets))
//        var rect = super.textRect(forBounds: bounds)
//        if rightAccessoryView != .none {
//            if UIApplication.isLeftToRightLayout {
//                rect = rect.inset(by: .init(top: 0, left: rightViewRect(forBounds: bounds).width, bottom: 0, right: 0))
//            } else {
//                rect = rect.inset(by: .init(top: 0, left: 0, bottom: 0, right: leftViewRect(forBounds: bounds).width))
//            }
//        }
//        return rect.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds.inset(by: textInsets))
    }
    
//    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
//        let leftToRight = UIApplication.isLeftToRightLayout
//        return leftToRight
//            ? rightAccessoryViewRect(forBounds: bounds, leftToRight: leftToRight)
//            : leftAccessoryViewRect(forBounds: bounds, leftToRight: leftToRight)
//    }
//
//    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//        let leftToRight = UIApplication.isLeftToRightLayout
//        return leftToRight
//            ? leftAccessoryViewRect(forBounds: bounds, leftToRight: leftToRight)
//            : rightAccessoryViewRect(forBounds: bounds, leftToRight: leftToRight)
//    }
//
//    private func rightAccessoryViewRect(forBounds bounds: CGRect, leftToRight: Bool) -> CGRect {
//        switch rightAccessoryView {
//        case .none: return .zero
//
//        case .confirmButton:
//            return leftToRight
//                ? .init(x: bounds.maxX - confirmButtonWidth, y: bounds.origin.y, width: confirmButtonWidth, height: bounds.height)
//                : .init(x: bounds.origin.x, y: bounds.origin.y, width: confirmButtonWidth, height: bounds.height)
//
//        case .guidanceDot:
//            return leftToRight
//                ? .init(x: bounds.maxX - guidanceDotViewWidth, y: bounds.origin.y, width: guidanceDotViewWidth, height: bounds.height)
//                : .init(x: bounds.origin.x, y: bounds.origin.y, width: guidanceDotViewWidth, height: bounds.height)
//
//        case .custom:
//            let w = customRightView?.intrinsicContentSize.width ?? 0
//            return leftToRight
//                ? .init(x: bounds.maxX - w, y: bounds.origin.y, width: w, height: bounds.height)
//                : .init(x: bounds.origin.x, y: bounds.origin.y, width: w, height: bounds.height)
//        }
//    }
//
//    private func leftAccessoryViewRect(forBounds bounds: CGRect, leftToRight: Bool) -> CGRect {
//        switch leftAccessoryView {
//        case .none: return .zero
//
//        case .countryCode:
//            return leftToRight
//                ? .init(x: bounds.origin.x, y: bounds.origin.y, width: countryCodeViewWidth, height: bounds.height)
//                : .init(x: bounds.maxX - countryCodeViewWidth, y: bounds.origin.y, width: countryCodeViewWidth, height: bounds.height)
//        }
//    }
}
