
import Foundation

extension UIFont {
    @objc static public func wr_preferredContentSizeMultiplier(for contentSizeCategory: UIContentSizeCategory) -> CGFloat {
        switch contentSizeCategory {
        case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return 26.0 / 16.0
        case UIContentSizeCategory.accessibilityExtraExtraLarge:      return 25.0 / 16.0
        case UIContentSizeCategory.accessibilityExtraLarge:           return 24.0 / 16.0
        case UIContentSizeCategory.accessibilityLarge:                return 23.0 / 16.0
        case UIContentSizeCategory.accessibilityMedium:               return 22.0 / 16.0
        case UIContentSizeCategory.extraExtraExtraLarge:              return 22.0 / 16.0
        case UIContentSizeCategory.extraExtraLarge:                   return 20.0 / 16.0
        case UIContentSizeCategory.extraLarge:                        return 18.0 / 16.0
        case UIContentSizeCategory.large:                             return 1.0
        case UIContentSizeCategory.medium:                            return 15.0 / 16.0
        case UIContentSizeCategory.small:                             return 14.0 / 16.0
        case UIContentSizeCategory.extraSmall:                        return 13.0 / 16.0
        default:
            return 1.0
        }
    }
}
