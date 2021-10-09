
import Foundation
import Down

import WireLinkPreview
import WireUtilities


extension NSAttributedString {
    
    static var paragraphStyle: NSParagraphStyle = {
        return defaultParagraphStyle()
    }()
    
    static var previewParagraphStyle: NSParagraphStyle {
        return defaultPreviewParagraphStyle()
    }
    
    static var style: DownStyle = {
        return defaultMarkdownStyle()
    }()
    
    static var translationStyle: DownStyle = {
        return defaultTranslationMarkdownStyle()
    }()
    
    static var previewStyle: DownStyle = {
        return previewMarkdownStyle()
    }()
    
    static var linkDataDetector: NSDataDetector? = {
        return try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    }()
    
    /// This method needs to be called as soon as the preferredContentSizeCategory is changed
    @objc
    static func invalidateParagraphStyle() {
        paragraphStyle = defaultParagraphStyle()
    }
    
    /// This method needs to be called as soon as the text color configuration is changed.
    @objc
    static func invalidateMarkdownStyle() {
        style = defaultMarkdownStyle()
        previewStyle = previewMarkdownStyle()
    }
    
    fileprivate static func defaultParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.minimumLineHeight = 22 * UIFont.wr_preferredContentSizeMultiplier(for: UIApplication.shared.preferredContentSizeCategory)
        paragraphStyle.paragraphSpacing = 8
        
        return paragraphStyle
    }
    
    fileprivate static func defaultPreviewParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.paragraphSpacing = 0
        
        return paragraphStyle
    }
    
    static func previewMarkdownStyle() -> DownStyle {
        let style = DownStyle.preview
        
        style.baseFontColor = UIColor.dynamic(scheme: .title)
        style.codeColor = style.baseFontColor
        style.h1Color = style.baseFontColor
        style.h2Color = style.baseFontColor
        style.h3Color = style.baseFontColor
        style.quoteColor = style.baseFontColor
        
        style.baseParagraphStyle = previewParagraphStyle
        style.listItemPrefixColor = style.baseFontColor.withAlphaComponent(0.64)
        
        return style
    }
    
    static func defaultMarkdownStyle() -> DownStyle {
        let style = DownStyle.normal
       
        style.baseFont = UIFont(16.5, .regular)//UIFont.normalRegularFont
        style.baseFontColor = UIColor.dynamic(scheme: .title)
        style.baseParagraphStyle = paragraphStyle
        style.listItemPrefixColor = style.baseFontColor.withAlphaComponent(0.64)
        
        return style
    }
    
    static func defaultTranslationMarkdownStyle() -> DownStyle {
        let style = DownStyle.translation
        
        style.baseFont = UIFont(16.5, .regular)//UIFont.normalRegularFont
        style.baseFontColor = UIColor.dynamic(scheme: .subtitle)
        style.baseParagraphStyle = paragraphStyle
        style.listItemPrefixColor = style.baseFontColor.withAlphaComponent(0.64)
        
        return style
    }
    
    
    @objc
    static func formatForPreview(message: ZMTextMessageData, inputMode: Bool, variant: ColorSchemeVariant = ColorScheme.default.variant) -> NSAttributedString {
        var plainText = message.messageText ?? ""
        
        let isMarkDown = message.isMarkDown

        // Substitute mentions with text markers
        let mentionTextObjects = plainText.replaceMentionsWithTextMarkers(mentions: message.mentions)
        
        var markdownText: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        if isMarkDown {
            // Perform markdown parsing
            markdownText = NSMutableAttributedString.markdown(from: plainText, style: previewStyle)
        } else {
            markdownText = NSMutableAttributedString(attributedString: plainText && previewStyle.toAttribute())
        }
        
        // Highlight mentions using previously inserted text markers
        markdownText.highlight(mentions: mentionTextObjects, paragraphStyle: nil)
        
        // Remove trailing link if we show a link preview
        let links = markdownText.links()

        // Do emoji substition (but not inside link or mentions)
        let linkAttachmentRanges = links.compactMap { Range<Int>($0.range) }
        let mentionRanges = mentionTextObjects.compactMap{ $0.range(in: markdownText.string as String)}
        markdownText.replaceEmoticons(excluding: linkAttachmentRanges + mentionRanges)
        markdownText.removeTrailingWhitespace()

        if !inputMode {
            markdownText.changeFontSizeIfMessageContainsOnlyEmoticons(to: 32)
        }
        
        markdownText.removeAttribute(.link, range: NSRange(location: 0, length: markdownText.length))
        markdownText.addAttribute(.foregroundColor, value: UIColor.dynamic(scheme: .title), range: NSRange(location: 0, length: markdownText.length))
        return markdownText
    }
    
    @objc
    static func format(message: ZMTextMessageData, isObfuscated: Bool) -> NSAttributedString {
        
        var plainText = message.messageText ?? ""
        
        let isMarkDown = message.isMarkDown
        
        guard !isObfuscated else {
            let attributes: [NSAttributedString.Key : Any] = [ .font : UIFont(name: "RedactedScript-Regular", size: 18)!,
                                                               .foregroundColor: UIColor.accent(),
                                                               .paragraphStyle: paragraphStyle]
            return NSAttributedString(string: plainText, attributes: attributes)
        }
        
        // Substitute mentions with text markers
        let mentionTextObjects = plainText.replaceMentionsWithTextMarkers(mentions: message.mentions)
        
        var markdownText: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        if isMarkDown {
            // Perform markdown parsing
            markdownText = NSMutableAttributedString.markdown(from: plainText, style: style)
        } else {
            markdownText = NSMutableAttributedString(attributedString: plainText && style.toAttribute())
        }
        
        // Highlight mentions using previously inserted text markers
        markdownText.highlight(mentions: mentionTextObjects)

        // Remove trailing link if we show a link preview
//        if let linkPreview = message.linkPreview {
//            markdownText.removeTrailingLink(for: linkPreview)
//        }

        // Do emoji substition (but not inside link or mentions)
//        let links = markdownText.links()
//        let linkAttachmentRanges = links.compactMap { Range<Int>($0.range) }
//        let mentionRanges = mentionTextObjects.compactMap{ $0.range(in: markdownText.string as String)}
//        markdownText.replaceEmoticons(excluding: linkAttachmentRanges + mentionRanges)

        markdownText.removeTrailingWhitespace()
        markdownText.changeFontSizeIfMessageContainsOnlyEmoticons()
        
        return markdownText
    }
    
    @objc
    static func formatTranslation(_ plainText: String) -> NSAttributedString {
        let markdownText = NSMutableAttributedString(attributedString: plainText && translationStyle.toAttribute())
        markdownText.removeTrailingWhitespace()
        markdownText.changeFontSizeIfMessageContainsOnlyEmoticons()
        return markdownText
    }
    
    func links() -> [URLWithRange] {
        return NSDataDetector.linkDetector?.detectLinksAndRanges(in: self.string, excluding: []) ?? []
    }
    
}

extension NSMutableAttributedString {
    
    func replaceEmoticons(excluding excludedRanges: [Range<Int>]) {
        beginEditing(); defer { endEditing() }

        let allowedIndexSet = IndexSet(integersIn: Range<Int>(wholeRange)!, excluding: excludedRanges)

        ///reverse the order of replacing, if we start replace from the beginning, the string may be shorten and other ranges may be invalid.
        for range in allowedIndexSet.rangeView.sorted(by: {$0.lowerBound > $1.lowerBound}) {
            let convertedRange = NSRange(location: range.lowerBound, length: range.upperBound - range.lowerBound)
            mutableString.resolveEmoticonShortcuts(in: convertedRange)
        }
    }
    
    func changeFontSizeIfMessageContainsOnlyEmoticons(to fontSize: CGFloat = 40) {
        //containsOnlyEmojiWithSpaces 
        let trimString = (string as String).trimmingCharacters(in: .whitespacesAndNewlines)
        if  trimString.count == 1 && (trimString as String).containsOnlyEmojiWithSpaces {
            setAttributes([.font: UIFont.systemFont(ofSize: fontSize)], range: wholeRange)
        }
    }
    
    func removeTrailingWhitespace() {
        let trailingWhitespaceRange = mutableString.rangeOfCharacter(from: .whitespacesAndNewlines, options: [.anchored, .backwards])
        
        if trailingWhitespaceRange.location != NSNotFound {
            mutableString.deleteCharacters(in: trailingWhitespaceRange)
        }
    }
    
    func removeTrailingLink(for linkPreview: LinkMetadata) {
        let text = self.string
        
        guard
            let linkPreviewRange = text.range(of: linkPreview.originalURLString, options: .backwards, range: nil, locale: nil),
            linkPreviewRange.upperBound == text.endIndex
        else {
            return
        }

        mutableString.replaceCharacters(in: NSRange(linkPreviewRange, in: text), with: "")
    }

}


fileprivate extension String {
    
    mutating func replaceMentionsWithTextMarkers(mentions: [Mention]) -> [TextMarker<Mention>] {
        return mentions.sorted(by: {
            return $0.range.location > $1.range.location
        }).compactMap({ mention in
            guard let range = Range(mention.range, in: self) else { return nil }
            
            let name = String(self[range].dropFirst()) // drop @
            let textObject = TextMarker<Mention>(mention, replacementText: name)
            
            replaceSubrange(range, with: textObject.token)
            
            return textObject
        })
    }
    
}
