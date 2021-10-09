
import UIKit

class DetailsCollectionViewCell: SeparatorCollectionViewCell {
    
    let accessoryTextField = SimpleTextField()

    private let leftIconView = UIImageView()
    
    private let accessoryIconView = UIImageView()
    private let accessoryContentIconView = UIImageView()
    private let accessoryHeaderImgView = UIImageView()
    private let accessorySwitchView = UISwitch()
    
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()

    private var titleStackView: UIStackView!
    var contentStackView: UIStackView!
    private var accessoryStackView: UIStackView!
    private var leftIconContainer: UIView!
    
    private var contentLeadingConstraint: NSLayoutConstraint!
    internal var accessoryIconViewWithConstraint: NSLayoutConstraint!
    internal var accessoryIconViewHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties

    var titleBolded: Bool {
        set {
            titleLabel.font = newValue ? FontSpec.init(.normal, .semibold).font! : FontSpec.init(.normal, .light).font!
        }

        get {
            return titleLabel.font == FontSpec.init(.normal, .semibold).font
        }
    }

    var icon: UIImage? {
        get { return leftIconView.image }
        set { updateIcon(newValue) }
    }

    var accessory: UIImage? {
        get { return accessoryIconView.image }
        set { updateAccessory(newValue) }
    }
    
    var accessoryHeaderImg: UIImage? {
        get { return accessoryHeaderImgView.image }
        set { updateAccessoryHeaderImg(newValue) }
    }
    
    var accessoryContent: UIImage? {
        get { return accessoryContentIconView.image }
        set { updateAccessoryContent(newValue) }
    }
    
    var accessoryTextFieldString: String? {
        get { return accessoryTextField.text }
        set { updateAccessoryTextField(newValue) }
    }
    
    var accessorySwitch: Bool {
        get {return accessorySwitchView.isOn}
        set {updateAccessorySwitch(newValue)}
    }
    
    var enableSwitch: Bool {
        get { return accessorySwitchView.isOn}
        set { accessorySwitchView.isEnabled = newValue}
    }

    var switchIsHidden: Bool {
        get { return accessorySwitchView.isHidden }
        set { accessorySwitchView.isHidden = newValue }
    }
    

    var title: String? {
        get { return titleLabel.text }
        set { updateTitle(newValue) }
    }

    var status: String? {
        get { return statusLabel.text }
        set { updateStatus(newValue) }
    }
    
    var disabled: Bool = false {
        didSet {
            updateDisabledState()
        }
    }

    // MARK: - Configuration

    override func setUp() {
        super.setUp()

        leftIconView.translatesAutoresizingMaskIntoConstraints = false
        leftIconView.contentMode = .scaleAspectFit
        leftIconView.setContentHuggingPriority(.required, for: .horizontal)

        accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconView.contentMode = .scaleAspectFit
        accessoryIconView.layer.masksToBounds = true
        
        accessoryHeaderImgView.translatesAutoresizingMaskIntoConstraints = false
        accessoryHeaderImgView.contentMode = .scaleAspectFill
        accessoryHeaderImgView.layer.masksToBounds = true
        accessoryHeaderImgView.layer.cornerRadius = 12
        accessoryHeaderImgView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        accessoryHeaderImgView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        accessoryContentIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryContentIconView.contentMode = .scaleAspectFit
        
        accessoryTextField.translatesAutoresizingMaskIntoConstraints = false
        accessoryTextField.font = FontSpec.init(.normal, .light).font!
        accessoryTextField.returnKeyType = .done
        accessoryTextField.backgroundColor = .clear
        accessoryTextField.textInsets = UIEdgeInsets.zero
        accessoryTextField.textAlignment = .right
        accessoryTextField.widthAnchor.constraint(equalToConstant: 96).isActive = true
        accessoryTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        accessoryStackView = UIStackView(arrangedSubviews: [])
        accessoryStackView.axis = .horizontal
        accessoryStackView.distribution = .fill
        accessoryStackView.alignment = .center
        accessoryStackView.translatesAutoresizingMaskIntoConstraints = false
        accessoryStackView.spacing = 24
        
        accessorySwitchView.isEnabled = false
        accessorySwitchView.addTarget(self, action: #selector(DetailsCollectionViewCell.switchChange(value:)), for: .valueChanged)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = FontSpec.init(.normal, .light).font!

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = FontSpec.init(.small, .regular).font!
        statusLabel.numberOfLines = 2
        let statusWidth =  UIScreen.main.bounds.width * 282/375
        statusLabel.widthAnchor.constraint(equalToConstant: statusWidth).isActive = true
        leftIconContainer = UIView()
        leftIconContainer.addSubview(leftIconView)
        leftIconContainer.translatesAutoresizingMaskIntoConstraints = false
        leftIconContainer.widthAnchor.constraint(equalToConstant: 64).isActive = true
        leftIconContainer.heightAnchor.constraint(equalTo: leftIconView.heightAnchor).isActive = true
        leftIconContainer.centerXAnchor.constraint(equalTo: leftIconView.centerXAnchor).isActive = true
        leftIconContainer.centerYAnchor.constraint(equalTo: leftIconView.centerYAnchor).isActive = true

        let iconViewSpacer = UIView()
        iconViewSpacer.translatesAutoresizingMaskIntoConstraints = false
        iconViewSpacer.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        titleStackView = UIStackView(arrangedSubviews: [titleLabel])
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView = UIStackView(arrangedSubviews: [titleStackView, iconViewSpacer,accessoryStackView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(contentStackView)
        contentLeadingConstraint = contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24)
        contentLeadingConstraint.isActive = true

        contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
    }

    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        let sectionTextColor = UIColor.dynamic(scheme: .subtitle)
        backgroundColor = UIColor.dynamic(scheme: .cellBackground)
        statusLabel.textColor = sectionTextColor
        updateDisabledState()
    }

    // MARK: - Layout

    private func updateIcon(_ newValue: UIImage?) {
        if let value = newValue {
            leftIconView.image = value
            leftIconView.isHidden = false
            leftIconContainer.isHidden = false
            
            contentStackView.insertArrangedSubview(leftIconContainer, at: 0)
            
            contentLeadingConstraint.constant = 0
            separatorLeadingInset = 64
        } else {
            leftIconView.isHidden = true
            leftIconContainer.isHidden = true
            
            contentStackView.removeArrangedSubview(leftIconContainer)
            
            contentLeadingConstraint.constant = 24
            separatorLeadingInset = 24
        }
    }

    private func updateTitle(_ newValue: String?) {
        if let value = newValue {
            titleLabel.text = value
            titleLabel.isHidden = false
        } else {
            titleLabel.isHidden = true
        }
    }

    private func updateStatus(_ newValue: String?) {
        if let value = newValue {
            statusLabel.text = value
            statusLabel.isHidden = false
            
            titleStackView.addArrangedSubview(statusLabel)
        } else {
            statusLabel.isHidden = true
            
            titleStackView.removeArrangedSubview(statusLabel)
        }
    }

    private func updateAccessory(_ newValue: UIImage?) {
        if let value = newValue {
            accessoryIconView.image = value
            accessoryIconView.isHidden = false
            
            accessoryStackView.addArrangedSubview(accessoryIconView)
        } else {
            accessoryIconView.isHidden = true
            
            accessoryStackView.removeArrangedSubview(accessoryIconView)
        }
    }
    
    private func updateAccessoryHeaderImg(_ newValue: UIImage?) {
        if let value = newValue {
            accessoryHeaderImgView.image = value
            accessoryHeaderImgView.isHidden = false
            
            accessoryStackView.addArrangedSubview(accessoryHeaderImgView)
        } else {
            accessoryHeaderImgView.isHidden = true
            
            accessoryStackView.removeArrangedSubview(accessoryHeaderImgView)
        }
    }
    
    private func updateAccessoryContent(_ newValue: UIImage?) {
        if let value = newValue {
            accessoryContentIconView.image = value
            accessoryContentIconView.isHidden = false
            
            accessoryStackView.insertArrangedSubview(accessoryContentIconView, at: 0)
        } else {
            accessoryContentIconView.isHidden = true
            
            accessoryStackView.removeArrangedSubview(accessoryContentIconView)
        }
    }
    
    private func updateAccessoryTextField(_ newValue: String?) {
        if let value = newValue {
            accessoryTextField.isHidden = false
            accessoryTextField.text = value
            
            accessoryStackView.addArrangedSubview(accessoryTextField)
        } else {
            accessoryTextField.isHidden = true
            accessoryStackView.removeArrangedSubview(accessoryTextField)
        }
    }
    
    private func updateAccessorySwitch(_ newValue: Bool) {
        accessorySwitchView.isHidden = false
        accessorySwitchView.isEnabled = true
        accessorySwitchView.isOn = newValue
        accessoryStackView.addArrangedSubview(accessorySwitchView)
    }
    
    private func updateDisabledState() {
        titleLabel.textColor = disabled ? UIColor.dynamic(scheme: .placeholder) : UIColor.dynamic(scheme: .title)
    }
    
    // MARK ---Action
    
    @objc public func switchChange(value: UISwitch) {
        fatal("Your subclasses must implement `switchChange(value:Bool)`.")
    }
}
