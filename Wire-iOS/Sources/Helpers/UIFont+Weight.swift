
import Foundation

public extension UIFont {
    
    /// Returns a font object that is the same as the receiver but which has the specified weight
    func withWeight(_ weight: Weight) -> UIFont {
        
        // Remove bold trait since we will modify the weight
        var symbolicTraits = fontDescriptor.symbolicTraits
        symbolicTraits.remove(.traitBold)
        
        var traits = fontDescriptor.fontAttributes[.traits] as? [String : Any] ?? [:]
        traits[kCTFontWeightTrait as String] = weight
        traits[kCTFontSymbolicTrait as String] = symbolicTraits.rawValue
        
        var fontAttributes: [UIFontDescriptor.AttributeName : Any] = [:]
        fontAttributes[.family] = familyName
        fontAttributes[.traits] = traits
        
        return UIFont(descriptor: UIFontDescriptor(fontAttributes: fontAttributes), size: pointSize)
    }
    
}
