
import Foundation

/// The purpose of this subclass of NSTextAttachment is to render a mention in the input bar.
/// It also keeps a reference to the `UserType` describing the User being mentioned.
final class MentionTextAttachment: NSTextAttachment {
    
    // Color used for the mention
    let color: UIColor

    /// The text the attachment renders, this is the name passed to init prefixed with an "@".
    var attributedText: NSAttributedString
    
    /// Font used for the mention, this gets updated when from the underlying text storage
    var font: UIFont
    
    /// Fitting size used when the mention was rendered the last time
    var lastFittingSize: CGSize = .zero
    
    /// The user being mentioned.
    let user: UserType
    
    static var paragraphStyle: NSParagraphStyle = {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return paragraphStyle
    }()
    
    init(user: UserType, color: UIColor = .accent()) {
        self.font = .normalLightFont
        self.color = color
        self.user = user
        self.attributedText = type(of: self).attributedMentionString(user: user, font: font, color: color)
        
        super.init(data: nil, ofType: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateImageIfNeeded(for textContainer: NSTextContainer?, characterIndex charIndex: Int) {
        guard let font = textContainer?.layoutManager?.textStorage?.attribute(.font, at: charIndex, effectiveRange: nil) as? UIFont,
              let textContainerSize = textContainer?.size else { return }
        
        guard font != self.font || textContainerSize != lastFittingSize else { return }
        
        self.font = font
        self.lastFittingSize = textContainerSize
        self.attributedText = type(of: self).attributedMentionString(user: user, font: font, color: color)
        
        image = mentionImage(fittingIntoSize: textContainerSize)
    }

    private func mentionImage(fittingIntoSize size: CGSize) -> UIImage? {
        bounds = attributedText.boundingRect(with: size, options: [], context: nil)
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        attributedText.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    private class func attributedMentionString(user: UserType, font: UIFont, color: UIColor) -> NSAttributedString {
        // Replace all spaces with non-breaking space to avoid wrapping when displaying mention
        let nameWithNonBreakingSpaces = user.name?.replacingOccurrences(of: String.breakingSpace, with: String.nonBreakingSpace)
        return "@" + (nameWithNonBreakingSpaces ?? "") && font && color && [.paragraphStyle : paragraphStyle]
    }
    
    override func attachmentBounds(for textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        updateImageIfNeeded(for: textContainer, characterIndex: charIndex)
        
        return super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
    }
    
}

fileprivate extension CGSize {
    static let max = CGSize(width: .max, height: .max)
}
