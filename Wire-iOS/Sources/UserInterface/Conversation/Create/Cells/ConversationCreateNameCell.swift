
import Foundation

class ConversationCreateNameCell: UICollectionViewCell {
    
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
        textField.accessibilityIdentifier = "textfield.newgroup.name"
        textField.placeholder = "conversation.create.group_name.placeholder".localized(uppercased: true)
                
        contentView.addSubview(textField)
        textField.fitInSuperview()
        
        configureColors()
    }
    
    private func configureColors() {
        textField.applyColorScheme(variant)
    }
}
