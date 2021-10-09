
import Foundation

/**
 Marks a class which supports different color schemes.
 
 A themeable class should be redraw it self  when `colorSchemeVariant` is changed.
 
 **Note:**
 It is recommened that `colorSchemeVariant` is marked as a dynamic property
 in order for it work with `UIAppearance`.
 */
protocol Themeable {
    
    /// Color scheme variant which should be applied to the view
    var colorSchemeVariant : ColorSchemeVariant { get set }
    
    /// Applies a color scheme to a view
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant)
    
}

extension UIView {
    
    /// Applies a color scheme to all subviews recursively.
    func applyColorSchemeOnSubviews(_ colorSchemeVariant: ColorSchemeVariant) {
        for subview in subviews {
            if let themable = subview as? Themeable {
                themable.applyColorScheme(colorSchemeVariant)
            }
            
            subview.applyColorSchemeOnSubviews(colorSchemeVariant)
        }
    }
    
}


