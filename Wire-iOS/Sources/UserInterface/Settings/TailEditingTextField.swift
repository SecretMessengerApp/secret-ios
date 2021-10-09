

import UIKit

/**
 * @abstract The purpose of this subclass of UITextField is to give the possibility to edit the right-aligned text field
 * with spaces. Default implementation collapses the trailing spaces as you type, which looks confusing. This control
 * can be used "as-is" without any additional configuration.
 */
class TailEditingTextField: UITextField {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        self.addTarget(self, action: #selector(TailEditingTextField.replaceNormalSpacesWithNonBreakingSpaces), for: UIControl.Event.editingDidBegin)
        self.addTarget(self, action: #selector(TailEditingTextField.replaceNormalSpacesWithNonBreakingSpaces), for: UIControl.Event.editingChanged)
        self.addTarget(self, action: #selector(TailEditingTextField.replaceNonBreakingSpacesWithNormalSpaces), for: UIControl.Event.editingDidEnd)
    }
    
    @objc func replaceNormalSpacesWithNonBreakingSpaces() {
        guard let isContainsNormalSpace = (self.text?.contains(String.breakingSpace)), isContainsNormalSpace else {
            return }

        self.text = self.text?.replacingOccurrences(of: String.breakingSpace, with: String.nonBreakingSpace)
    }
    
    @objc func replaceNonBreakingSpacesWithNormalSpaces() {
        guard let isContainsNonBreakingSpace = (self.text?.contains(String.nonBreakingSpace)), isContainsNonBreakingSpace else { return }
        
        self.text = self.text?.replacingOccurrences(of: String.nonBreakingSpace, with: String.breakingSpace)
    }
}
