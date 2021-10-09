//


import Foundation
import Cartography
import UIKit

protocol TextSearchInputViewDelegate: class {
    func searchView(_ searchView: TextSearchInputView, didChangeQueryTo: String)
    func searchViewShouldReturn(_ searchView: TextSearchInputView) -> Bool
}

final class TextSearchInputView: UIView {
    let iconView = ThemedImageView()
    let searchInput = UITextView()
    let placeholderLabel = UILabel()
    let cancelButton = IconButton(style: .default)

    private let spinner = ProgressSpinner()
    
    weak var delegate: TextSearchInputViewDelegate?
    var query: String = "" {
        didSet {
            if query != oldValue {
                self.updateForSearchQuery()
                self.delegate?.searchView(self, didChangeQueryTo: self.query)
            }
        }
    }
    
    var placeholderString: String = "" {
        didSet {
            self.placeholderLabel.text = placeholderString
        }
    }

    var isLoading: Bool = false {
        didSet {
            spinner.isAnimating = isLoading
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .dynamic(scheme: .barBackground)
        
        iconView.setIcon(.search, size: .tiny, color: .dynamic(scheme: .iconNormal))
        iconView.contentMode = .center
        
        searchInput.delegate = self
        searchInput.autocorrectionType = .no
        searchInput.accessibilityLabel = "Search"
        searchInput.accessibilityIdentifier = "search input"
        searchInput.layer.cornerRadius = 4
        searchInput.backgroundColor = .dynamic(scheme: .inputBackground)
        searchInput.textContainerInset = UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 8)
        searchInput.font = .normalFont
        searchInput.textColor = .dynamic(scheme: .title)
        
        placeholderLabel.textAlignment = .natural
        placeholderLabel.isAccessibilityElement = false
        placeholderLabel.font = .smallRegularFont
        placeholderLabel.textColor = .dynamic(scheme: .placeholder)

        cancelButton.setIcon(.clearInput, size: .tiny, for: .normal)
        cancelButton.setIconColor(scheme: .iconNormal, for: .normal)
        cancelButton.alpha = 0.4
        cancelButton.addTarget(self, action: #selector(TextSearchInputView.onCancelButtonTouchUpInside(_:)), for: .touchUpInside)
        cancelButton.isHidden = true
        cancelButton.accessibilityIdentifier = "cancel search"

        spinner.color = .dynamic(scheme: .note)
        spinner.iconSize = StyleKitIcon.Size.tiny.rawValue
        [searchInput, cancelButton, placeholderLabel, spinner, iconView].forEach(addSubview)

        createConstraints()
    }
    
    private func createConstraints() {
        constrain(self, iconView, searchInput, placeholderLabel, cancelButton) { selfView, iconView, searchInput, placeholderLabel, cancelButton in
            iconView.leading == searchInput.leading + 8
            iconView.centerY == searchInput.centerY
            
            selfView.height <= 100
            
            searchInput.edges == inset(selfView.edges, UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))

            placeholderLabel.leading == searchInput.leading + 32
            placeholderLabel.top == searchInput.top
            placeholderLabel.bottom == searchInput.bottom
            placeholderLabel.trailing == cancelButton.leading
        }

        constrain(self, searchInput, cancelButton, spinner) { view, searchInput, cancelButton, spinner in
            cancelButton.centerY == view.centerY
            cancelButton.trailing == searchInput.trailing - 8
            cancelButton.width == StyleKitIcon.Size.tiny.rawValue
            cancelButton.height == StyleKitIcon.Size.tiny.rawValue

            spinner.trailing == cancelButton.leading - 6
            spinner.centerY == cancelButton.centerY
            spinner.width == StyleKitIcon.Size.tiny.rawValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatal("init?(coder aDecoder: NSCoder) is not implemented")
    }
    
    @objc func onCancelButtonTouchUpInside(_ sender: AnyObject!) {
        self.query = ""
        self.searchInput.text = ""
        self.searchInput.resignFirstResponder()
    }
    
    fileprivate func updatePlaceholderLabel() {
        self.placeholderLabel.isHidden = !self.query.isEmpty
    }
    
    fileprivate func updateForSearchQuery() {
        self.updatePlaceholderLabel()
        cancelButton.isHidden = self.query.isEmpty
    }
}

extension TextSearchInputView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else {
            return true
        }
        let containsReturn = text.rangeOfCharacter(from: .newlines, options: [], range: .none) != .none
        
        let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
        self.query = containsReturn ? currentText : newText
        
        if containsReturn {
            let shouldReturn = delegate?.searchViewShouldReturn(self) ?? true
            if shouldReturn {
                textView.resignFirstResponder()
            }
        }
        
        return !containsReturn
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.updatePlaceholderLabel()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.updatePlaceholderLabel()
    }
}
