
import UIKit
import Foundation

class FolderCreationNameCell: UICollectionViewCell {
 
    let textField = SimpleTextField()
    
    var variant : ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != variant else { return }
            configureColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isAccessibilityElement = true
        textField.accessibilityIdentifier = "textfield.newfolder.name"
        textField.placeholder = "folder.creation.name.placeholder".localized(uppercased: true)
        
        contentView.addSubview(textField)
        textField.fitInSuperview()
        
        configureColors()
    }
    
    private func configureColors() {
        backgroundColor = UIColor.from(scheme: .barBackground, variant: variant)
        textField.applyColorScheme(variant)
    }
}
