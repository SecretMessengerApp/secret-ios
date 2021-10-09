
import Foundation
import UIKit
import WireSystem

private let zmLog = ZMSLog(tag: "TextView")

protocol InformalTextViewDelegate: class {
    func textView(_ textView: UITextView, hasImageToPaste image: MediaAsset)
    func textView(_ textView: UITextView, firstResponderChanged resigned: Bool)
}

class TextView: UITextView {

    weak var informalTextViewDelegate: InformalTextViewDelegate?

    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            placeholderLabel.sizeToFit()
            showOrHidePlaceholder()
        }
    }

    var attributedPlaceholder: NSAttributedString? {
        didSet {
            let mutableCopy: NSMutableAttributedString
            if let attributedPlaceholder = attributedPlaceholder {
                mutableCopy = NSMutableAttributedString(attributedString: attributedPlaceholder)
            } else {
                mutableCopy = NSMutableAttributedString()
            }
            mutableCopy.addAttribute(.foregroundColor, value: placeholderTextColor, range: NSRange(location: 0, length: mutableCopy.length))
            placeholderLabel.attributedText = mutableCopy
            placeholderLabel.sizeToFit()
            showOrHidePlaceholder()
        }
    }

    var placeholderTextColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }

    var placeholderFont: UIFont? {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }

    var placeholderTextTransform: TextTransform = .upper {
        didSet {
            placeholderLabel.textTransform = placeholderTextTransform
        }
    }

    var lineFragmentPadding: CGFloat = 0 {
        didSet {
            textContainer.lineFragmentPadding = lineFragmentPadding
        }
    }

    var placeholderTextAlignment: NSTextAlignment = NSTextAlignment.natural {
        didSet {
            placeholderLabel.textAlignment = placeholderTextAlignment
        }
    }
    var language: String?

    private let placeholderLabel: TransformLabel = TransformLabel()
    private var placeholderLabelLeftConstraint: NSLayoutConstraint?
    private var placeholderLabelRightConstraint: NSLayoutConstraint?
    private var placeholderLabelCenterYConstraint: NSLayoutConstraint?

    private var shouldDrawPlaceholder = false

    override var accessibilityValue: String? {
        set {
            super.accessibilityValue = newValue
        }
        
        get {
            return text.isEmpty ? placeholderLabel.accessibilityValue : super.accessibilityValue
        }
    }
    
    override var text: String! {
        didSet {
            showOrHidePlaceholder()
        }
    }

    override var attributedText: NSAttributedString! {
        didSet {
            showOrHidePlaceholder()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    // MARK: Setup
    private func setup() {
        placeholderTextContainerInset = textContainerInset

        NotificationCenter.default.addObserver(self, selector: #selector(textChanged(_:)), name: UITextView.textDidChangeNotification, object: self)

        setupPlaceholderLabel()

        if AutomationHelper.sharedHelper.disableAutocorrection {
            autocorrectionType = .no
        }
    }

    @objc
    func textChanged(_ note: Notification?) {
        showOrHidePlaceholder()
    }

    @objc
    func showOrHidePlaceholder() {
        placeholderLabel.alpha = text.isEmpty ? 1 : 0
    }

    // MARK: - Copy/Pasting
    override func paste(_ sender: Any?) {
        let pasteboard = UIPasteboard.general
        zmLog.debug("types available: \(pasteboard.types)")

        if pasteboard.hasImages,
            let image = UIPasteboard.general.mediaAsset() {
            informalTextViewDelegate?.textView(self, hasImageToPaste: image)
        } else if pasteboard.hasStrings {
            super.paste(sender)
        } else if pasteboard.hasURLs {
            if pasteboard.string?.isEmpty == false {
                super.paste(sender)
            } else if pasteboard.url != nil {
                super.paste(sender)
            }
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            let pasteboard = UIPasteboard.general
            return pasteboard.hasImages || pasteboard.hasStrings
        }

        return super.canPerformAction(action, withSender: sender)
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()

        informalTextViewDelegate?.textView(self, firstResponderChanged: resigned)

        return resigned
    }

    // MARK: Language
    override var textInputMode: UITextInputMode? {
        return overriddenTextInputMode
    }

    /// custom inset for placeholder, only left and right inset value is applied (The placeholder is align center vertically)
    var placeholderTextContainerInset: UIEdgeInsets = .zero {
        didSet {
            placeholderLabelLeftConstraint?.constant = placeholderTextContainerInset.left
            placeholderLabelRightConstraint?.constant = placeholderTextContainerInset.right
        }
    }
    
    var placeholderTextContainerTopInset: CGFloat? {
        didSet {
            guard let topInset = placeholderTextContainerTopInset else { return }
            placeholderLabelCenterYConstraint?.isActive = false
            NSLayoutConstraint.activate([
                placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: topInset)
            ])
        }
    }

    private func setupPlaceholderLabel() {
        let linePadding = textContainer.lineFragmentPadding
        placeholderLabel.font = placeholderFont
        placeholderLabel.textColor = placeholderTextColor
        placeholderLabel.textTransform = placeholderTextTransform
        placeholderLabel.textAlignment = placeholderTextAlignment
        placeholderLabel.isAccessibilityElement = false

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(placeholderLabel)

        placeholderLabelLeftConstraint = placeholderLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: placeholderTextContainerInset.left + linePadding)
        placeholderLabelRightConstraint = placeholderLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: placeholderTextContainerInset.right - linePadding)
        placeholderLabelCenterYConstraint = placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        
        NSLayoutConstraint.activate([
            placeholderLabelLeftConstraint!,
            placeholderLabelRightConstraint!,
            placeholderLabelCenterYConstraint!
        ])
    }
}
