

extension NetworkQuality {
    func attributedString(color: UIColor) -> NSAttributedString? {
        if isNormal {
            return nil
        } else {
            let attachment = NSTextAttachment.textAttachment(for: .networkCondition, with: color, iconSize: .tiny)
            attachment.bounds = CGRect(x: 0.0, y: -4, width: attachment.image!.size.width, height: attachment.image!.size.height)
            let text = "conversation.status.poor_connection".localized(uppercased: true)
            let attributedText = text.attributedString.adding(font: FontSpec(.small, .semibold).font!, to: text).adding(color: color, to: text)
            return NSAttributedString(attachment: attachment) + " " + attributedText
        }
    }

    var isNormal: Bool {
        switch self {
        case .normal:
            return true
        case .medium, .poor:
            return false
        }
    }
}
