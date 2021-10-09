
import CoreGraphics

extension StyleKitIcon {

    /**
     * Represents the target size of an icon. You can either use standard values,
     * or use a raw CGFloat value, without needing to add another case.
     */

    public enum Size: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
        /// 12pt.
        case like
        
        /// 16pt.
        case tiny

        /// 20pt.
        case small

        /// 24pt.
        case medium

        /// 48pt.
        case large

        /// A custom size.
        case custom(CGFloat)

        // MARK: - Literal Conversion

        public init(floatLiteral value: Double) {
            self = .custom(CGFloat(value))
        }

        public init(integerLiteral value: Int) {
            self = .custom(CGFloat(value))
        }

        // MARK: - CGFloat Conversion

        /// The value to use to generate the icon.
        public var rawValue: CGFloat {
            switch self {
            case .like: return 12
            case .tiny: return 16
            case .small: return 20
            case .medium: return 24
            case .large: return 48
            case .custom(let value): return value
            }
        }

    }

}
