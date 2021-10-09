

import Foundation
import Down

extension DownStyle {
    
    
    public func toAttribute() -> [NSAttributedString.Key: Any] {
        
        var attribute = [NSAttributedString.Key: Any]()
        
        attribute[.foregroundColor] = self.baseFontColor
        
        attribute[.font] = self.baseFont
        
        attribute[.paragraphStyle] = self.baseParagraphStyle
        
        return attribute
        
    }
    
}
