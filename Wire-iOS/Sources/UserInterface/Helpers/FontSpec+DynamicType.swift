
import Foundation

extension FontSpec {
    
    var font: UIFont? {
        return defaultFontScheme.font(for: self)
    }
    
}
