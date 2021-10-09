
public class IconStringsBuilder {
    
    // Logic for composing attributed strings with:
    // - an icon (optional)
    // - a title
    // - an down arrow for tappable strings (optional)
    // - and, obviously, a color
    
    static func iconString(with icon: NSTextAttachment?, title: String, interactive: Bool, color: UIColor) -> NSAttributedString {
        return iconString(with: icon == nil ? [] : [icon!], title: title, interactive: interactive, color: color)
    }
    
    static func iconString(with icons: [NSTextAttachment], title: String, interactive: Bool, color: UIColor) -> NSAttributedString {
        
        var components: [NSAttributedString] = []
        
        // Adds shield/legalhold/availability/etc. icons
        icons.forEach { components.append(NSAttributedString(attachment: $0)) }

        // Adds the title
        components.append(title.attributedString)
        
        // Adds the down arrow if the view is interactive
        if interactive {
            components.append(NSAttributedString(attachment: .downArrow(color: color)))
        }
        
        // Mirror elements if in a RTL layout
        if !UIApplication.isLeftToRightLayout {
            components.reverse()
        }
        
        // Add a padding and combine the final attributed string
        let attributedTitle = components.joined(separator: "  ".attributedString)
        
        return attributedTitle && color
    }
}
