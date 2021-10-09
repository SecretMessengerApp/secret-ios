
import Foundation

// MARK: - Avatar

extension UIFont {
    class var avatarInitial: UIFont {
        return UIFont(11, .light)
    }
}

// Objective-C compatiblity layer for the Swift only FontSpec
@objc
extension UIFont {
    
    convenience init(_ size: CGFloat, _ weight: UIFont.Weight) {
        let desc = UIFontDescriptor(fontAttributes: [.name: "HelveticaNeue"])
        self.init(descriptor: desc, size: size)
    }
    
    // MARK: - Small
    
    class var smallFont: UIFont {
        return FontSpec(.small, .none).font!
    }

    class var smallLightFont: UIFont {
        return FontSpec(.small, .light).font!
    }

    class var smallRegularFont: UIFont {
        return FontSpec(.small, .regular).font!
    }
    
    class var smallMediumFont: UIFont {
        return FontSpec(.small, .medium).font!
    }
    
    class var smallSemiboldFont: UIFont {
        return FontSpec(.small, .semibold).font!
    }
    

    // MARK: - Normal

    class var normalFont: UIFont {
        return FontSpec(.normal, .none).font!
    }

    class var normalLightFont: UIFont {
        return FontSpec(.normal, .light).font!
    }

    class var normalRegularFont: UIFont {
        return FontSpec(.normal, .regular).font!
    }

    class var normalMediumFont: UIFont {
        return FontSpec(.normal, .medium).font!
    }

    class var normalSemiboldFont: UIFont {
        return FontSpec(.normal, .semibold).font!
    }

    // MARK: - Medium

    class var mediumFont: UIFont {
        return FontSpec(.medium, .none).font!
    }

    class var mediumSemiboldFont: UIFont {
        return FontSpec(.medium, .semibold).font!
    }

    class var mediumLightLargeTitleFont: UIFont {
        return FontSpec(.medium, .light, .largeTitle).font!
    }

    // MARK: - Large
    
    class var largeThinFont: UIFont {
        return FontSpec(.large, .thin).font!
    }
    
    class var largeLightFont: UIFont {
        return FontSpec(.large, .light).font!
    }
    
    class var largeRegularFont: UIFont {
        return FontSpec(.large, .regular).font!
    }
    
    class var largeMediumFont: UIFont {
        return FontSpec(.large, .medium).font!
    }
    
    class var largeSemiboldFont: UIFont {
        return FontSpec(.large, .semibold).font!
    }

    
}
