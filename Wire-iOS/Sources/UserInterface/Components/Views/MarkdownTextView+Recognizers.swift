
import Foundation

extension MarkdownTextView {
    func setupGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTextView(_:)))
        tapRecognizer.delegate = self
        addGestureRecognizer(tapRecognizer)
    }

    @objc func didTapTextView(_ recognizer: UITapGestureRecognizer) {
        var location = recognizer.location(in: self)
        location.x -= textContainerInset.left
        location.y -= textContainerInset.top

        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        selectTextAttachmentIfNeeded(at: characterIndex)
    }

    func selectTextAttachmentIfNeeded(at index: Int) {
        guard attributedText.wholeRange.contains(index) else { return }

        let attributes = attributedText.attributes(at: index, effectiveRange: nil)
        guard attributes[NSAttributedString.Key.attachment] as? MentionTextAttachment != nil else { return }

        guard let start = position(from: beginningOfDocument, offset: index) else { return }
        guard let end = position(from: start, offset: 1) else { return }

        selectedTextRange = textRange(from: start, to: end)
    }
}

extension MarkdownTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // prevent recognizing other UIPanGestureRecognizers at the same time, e.g. SplitViewController's panGestureRecognizers will dismiss the keyboard and this MarkdownTextView moves down immediately
        if otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
}
