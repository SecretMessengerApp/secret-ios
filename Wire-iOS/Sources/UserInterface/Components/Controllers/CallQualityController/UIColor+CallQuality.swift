
import UIKit

extension UIColor {
    enum CallQuality {
        static let backgroundDim        = UIColor.black.withAlphaComponent(0.6)
        static let contentBackground    = UIColor.white
        static let closeButton          = UIColor(hex: 0xDAD9DF)
        static let buttonHighlight      = UIColor.strongBlue.withAlphaComponent(0.5)
        static let title                = UIColor(hex: 0x323639)
        static let question             = UIColor.CallQuality.title.withAlphaComponent(0.56)
        static let score                = UIColor(hex: 0x272A2C)
        static let scoreBackground      = UIColor(hex: 0xF8F8F8)
        static let scoreHighlight       = UIColor.strongBlue
    }
}
