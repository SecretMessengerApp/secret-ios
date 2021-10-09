

import UIKit
import Cartography

enum SettingsCellPreview {
    case none
    case text(String)
    case badge(Int)
    case image(UIImage, Bool)
    case color(UIColor)

    case attributeText(NSAttributedString)

    case textAndValue(String)
}

protocol SettingsCellType: class {
    var titleText: String {get set}
    var preview: SettingsCellPreview {get set}
    var titleColor: UIColor {get set}
    var cellColor: UIColor? {get set}
    var descriptor: SettingsCellDescriptorType? {get set}
    var icon: StyleKitIcon? {get set}

    var detailText: String {get set}
}

 class SettingsTableCell: UITableViewCell, SettingsCellType {
    let iconImageView = UIImageView()
    let cellNameLabel: UILabel = {
        let label = UILabel()
        label.font = .normalLightFont
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.textColor = .dynamic(scheme: .title)
        return label
    }()
    let valueLabel = UILabel()
    let badge = RoundedBadge(view: UIView())
    var badgeLabel = UILabel()
    let imagePreview = UIImageView()
    let separatorLine = UIView()
    let topSeparatorLine = UIView()
    let lastSeparatorLine = UIView()
    var cellNameLabelToIconInset: NSLayoutConstraint!
    
    var cellNameLabelToBottomInset: NSLayoutConstraint!
    let cellDetailLabel = UILabel()
    var variant: ColorSchemeVariant? = .none {
        didSet {
            titleColor = UIColor.dynamic(scheme: .title)
        }
    }

    var titleText: String = "" {
        didSet {
            cellNameLabel.text = titleText
        }
    }
    
    var detailText: String = "" {
        didSet {
            if detailText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""{
                cellDetailLabel.text = nil
                cellNameLabelToBottomInset.isActive = true
            }else{
                cellDetailLabel.text = detailText
                cellNameLabelToBottomInset.isActive = false
            }
        }
    }

    var preview: SettingsCellPreview = .none {
        didSet {
            switch preview {
            case .attributeText(let attText):
                self.valueLabel.attributedText = attText
                self.badgeLabel.text = ""
                self.badge.isHidden = true
                self.imagePreview.image = .none
                self.imagePreview.backgroundColor = UIColor.clear
                self.imagePreview.accessibilityValue = nil
                self.imagePreview.isAccessibilityElement = false
                
            case .textAndValue(let string):
                //                self.valueLabel.text = string
                self.cellNameLabel.text = "\(self.titleText): \(string)"
                self.badgeLabel.text = ""
                self.badge.isHidden = true
                self.imagePreview.image = .none
                self.imagePreview.backgroundColor = UIColor.clear
                self.imagePreview.accessibilityValue = nil
                self.imagePreview.isAccessibilityElement = false
                
            case .text(let string):
                valueLabel.text = string
                badgeLabel.text = ""
                badge.isHidden = true
                imagePreview.image = .none
                imagePreview.backgroundColor = UIColor.clear
                imagePreview.accessibilityValue = nil
                imagePreview.isAccessibilityElement = false
                
            case .badge(let value):
                valueLabel.text = ""
                badgeLabel.text = "\(value)"
                badge.isHidden = false
                imagePreview.image = .none
                imagePreview.backgroundColor = UIColor.clear
                imagePreview.accessibilityValue = nil
                imagePreview.isAccessibilityElement = false
                
            case .image(let image, let needClip):
                if needClip {
                    imagePreview.clipsToBounds = true
                    imagePreview.layer.cornerRadius = 12
                } else {
                    imagePreview.clipsToBounds = false
                }
                valueLabel.text = ""
                badgeLabel.text = ""
                badge.isHidden = true
                imagePreview.image = image
                imagePreview.backgroundColor = UIColor.clear
                imagePreview.accessibilityValue = "image"
                imagePreview.isAccessibilityElement = true
                
            case .color(let color):
                valueLabel.text = ""
                badgeLabel.text = ""
                badge.isHidden = true
                imagePreview.image = .none
                imagePreview.layer.cornerRadius = 12
                imagePreview.backgroundColor = color
                imagePreview.clipsToBounds = true
                imagePreview.accessibilityValue = "color"
                imagePreview.isAccessibilityElement = true
                
            case .none:
                valueLabel.text = ""
                badgeLabel.text = ""
                badge.isHidden = true
                imagePreview.image = .none
                imagePreview.backgroundColor = UIColor.clear
                imagePreview.accessibilityValue = nil
                imagePreview.isAccessibilityElement = false
            }
        }
    }
    
    var icon: StyleKitIcon? = nil {
        didSet {
            if let icon = icon {
                if [.settingDarkMode, .settingLanguage, .settingAccount, .settingDevice, .settingBackup, .settingOption, .settingAdvanced, .settingAbout, .settingPrivacy].contains(icon) {
                    iconImageView.image = icon.image?.withColor(.dynamic(scheme: .iconNormal))
                } else {
                    iconImageView.setIcon(icon, size: .tiny, color: .dynamic(scheme: .iconNormal))
                }
                cellNameLabelToIconInset.isActive = true
            } else {
                iconImageView.image = nil
                cellNameLabelToIconInset.isActive = false
            }
        }
    }
    
    var isFirst: Bool = false {
        didSet {
            topSeparatorLine.isHidden = !isFirst
        }
    }
    var isLast: Bool = false {
        didSet{
            lastSeparatorLine.isHidden = !isLast
            separatorLine.isHidden = isLast
        }
    }
    
    var titleColor: UIColor = .dynamic(scheme: .title) {
        didSet {
            cellNameLabel.textColor = titleColor
        }
    }
    
    var cellColor: UIColor? {
        didSet {
            backgroundColor = cellColor
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateBackgroundColor()
    }
    
    var descriptor: SettingsCellDescriptorType?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        setupAccessibiltyElements()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupAccessibiltyElements()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        preview = .none
    }
    
    func setup() {
        backgroundColor = UIColor.dynamic(scheme: .cellBackground)
        backgroundView = UIView()
        selectedBackgroundView = UIView()
        
        iconImageView.contentMode = .center
        contentView.addSubview(iconImageView)
        
        constrain(contentView, iconImageView) { contentView, iconImageView in
            iconImageView.leading == contentView.leading + 24
            iconImageView.width == 16
            iconImageView.height == iconImageView.height
            iconImageView.centerY == contentView.centerY
        }
        
        cellNameLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        contentView.addSubview(cellNameLabel)
        contentView.addSubview(cellDetailLabel)
        contentView.addSubview(imagePreview)
        cellDetailLabel.textColor = UIColor.lightGray
        cellDetailLabel.font = UIFont(12, .regular)
        constrain(contentView, cellNameLabel, iconImageView, cellDetailLabel, imagePreview) { contentView, cellNameLabel, iconImageView, cellDetailLabel, imagePreview in
            cellNameLabelToIconInset = cellNameLabel.leading == iconImageView.trailing + 24
            cellNameLabel.leading == contentView.leading + 16 ~ 750.0
            cellNameLabel.top == contentView.top + 12
            cellNameLabelToBottomInset = cellNameLabel.bottom == contentView.bottom - 12
            
            cellDetailLabel.left == cellNameLabel.left
            cellDetailLabel.top == cellNameLabel.bottom + 12
            cellDetailLabel.right == imagePreview.left - 12
            cellDetailLabel.bottom == contentView.bottom - 12 ~ 750.0
        }
        
        cellNameLabelToIconInset.isActive = false
        cellNameLabelToBottomInset.isActive = true
        
        valueLabel.textColor = UIColor.lightGray
        valueLabel.font = UIFont.systemFont(ofSize: 17)
        valueLabel.textAlignment = .right
        
        contentView.addSubview(valueLabel)

        badgeLabel.font = FontSpec(.small, .medium).font
        badgeLabel.textAlignment = .center
        badgeLabel.textColor = .white
        
        badge.containedView.addSubview(badgeLabel)
        
        badge.backgroundColor = .dynamic(scheme: .badgeBackground)
        badge.isHidden = true
        contentView.addSubview(badge)
        
        let trailingBoundaryView = accessoryView ?? contentView

        constrain(contentView, cellNameLabel, valueLabel, trailingBoundaryView, badge) { contentView, cellNameLabel, valueLabel, trailingBoundaryView, badge in
            valueLabel.top == contentView.top - 8
            valueLabel.bottom == contentView.bottom + 8
            valueLabel.leading >= cellNameLabel.trailing + 8
            valueLabel.trailing == trailingBoundaryView.trailing - 16
            badge.center == valueLabel.center
            badge.height == 20
            badge.width >= 28
        }
        
        constrain(badge, badgeLabel) { badge, badgeLabel in
            badgeLabel.leading == badge.leading + 6
            badgeLabel.trailing == badge.trailing - 6
            badgeLabel.top == badge.top
            badgeLabel.bottom == badge.bottom
        }
        
        imagePreview.contentMode = .scaleAspectFit
        imagePreview.accessibilityIdentifier = "imagePreview"
        
        
        constrain(contentView, imagePreview) { contentView, imagePreview in
            imagePreview.width == imagePreview.height
            imagePreview.height == 24
            imagePreview.trailing == contentView.trailing - 16
            imagePreview.centerY == contentView.centerY
        }
        
        separatorLine.backgroundColor = UIColor.dynamic(scheme: .separator)
        separatorLine.isAccessibilityElement = false
        addSubview(separatorLine)
        
        constrain(self, separatorLine, cellNameLabel) { selfView, separatorLine, cellNameLabel in
            separatorLine.leading == cellNameLabel.leading
            separatorLine.trailing == selfView.trailing
            separatorLine.bottom == selfView.bottom
            separatorLine.height == .hairline
        }
        
        topSeparatorLine.backgroundColor = UIColor.dynamic(scheme: .separator)
        topSeparatorLine.isAccessibilityElement = false
        addSubview(topSeparatorLine)
        
        constrain(self, topSeparatorLine) { selfView, topSeparatorLine in
            topSeparatorLine.leading == selfView.leading
            topSeparatorLine.trailing == selfView.trailing
            topSeparatorLine.top == selfView.top
            topSeparatorLine.height == .hairline
        }
        
        lastSeparatorLine.backgroundColor = UIColor.dynamic(scheme: .separator)
        lastSeparatorLine.isAccessibilityElement = false
        addSubview(lastSeparatorLine)
        
        constrain(self, lastSeparatorLine) { selfView, lastSeparatorLine in
            lastSeparatorLine.leading == selfView.leading
            lastSeparatorLine.trailing == selfView.trailing
            lastSeparatorLine.bottom == selfView.bottom
            lastSeparatorLine.height == .hairline
        }


        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
        variant = .light
    }
    
    func setupAccessibiltyElements() {
        var currentElements = accessibilityElements ?? []
        currentElements.append(contentsOf: [cellNameLabel, valueLabel, imagePreview])
        accessibilityElements = currentElements
    }
    
    func updateBackgroundColor() {
        if let _ = cellColor {
            return
        }
        
        if isHighlighted && selectionStyle != .none {
            backgroundColor = UIColor.dynamic(scheme: .cellSelectedBackground)
            badge.backgroundColor = UIColor.white
            badgeLabel.textColor = UIColor.black
        }
        else {
            backgroundColor = UIColor.dynamic(scheme: .cellBackground)
        }
    }
}

 class SettingsGroupCell: SettingsTableCell {
    override func setup() {
        super.setup()
        accessoryType = .disclosureIndicator
    }
}

 class SettingsButtonCell: SettingsTableCell {
    override func setup() {
        super.setup()
        cellNameLabel.textColor = UIColor.dynamic(scheme: .title)
    }
}

 class SettingsToggleCell: SettingsTableCell {
    var switchView: UISwitch!
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        shouldGroupAccessibilityChildren = false
        let switchView = UISwitch(frame: CGRect.zero)
        switchView.addTarget(self, action: #selector(SettingsToggleCell.onSwitchChanged(_:)), for: .valueChanged)
        accessoryView = switchView
        switchView.isAccessibilityElement = true
        
        accessibilityElements = [cellNameLabel, switchView]

        self.switchView = switchView
    }
    
    @objc func onSwitchChanged(_ sender: UIResponder) {
        descriptor?.select(SettingsPropertyValue(switchView.isOn))
    }
}

 class SettingsValueCell: SettingsTableCell {
    override var descriptor: SettingsCellDescriptorType?{
        willSet {
            if let propertyDescriptor = descriptor as? SettingsPropertyCellDescriptorType {
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: propertyDescriptor.settingsProperty.propertyName.changeNotificationName), object: nil)
            }
        }
        didSet {
            if let propertyDescriptor = descriptor as? SettingsPropertyCellDescriptorType {
                NotificationCenter.default.addObserver(self, selector: #selector(SettingsValueCell.onPropertyChanged(_:)), name: NSNotification.Name(rawValue: propertyDescriptor.settingsProperty.propertyName.changeNotificationName), object: nil)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Properties observing
    
    @objc func onPropertyChanged(_ notification: Notification) {
        descriptor?.featureCell(self)
    }
}

 class SettingsTextCell: SettingsTableCell, UITextFieldDelegate {
    var textInput: UITextField!

    override func setup() {
        super.setup()
        selectionStyle = .none
        
        textInput = TailEditingTextField(frame: CGRect.zero)
        textInput.delegate = self
        textInput.textAlignment = .right
        textInput.textColor = UIColor.lightGray
        textInput.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
        textInput.isAccessibilityElement = true
        
        contentView.addSubview(textInput)

        createConstraints()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onCellSelected(_:)))
        contentView.addGestureRecognizer(tapGestureRecognizer)
    }

    func createConstraints(){
        let textInputSpacing = CGFloat(16)

        let trailingBoundaryView = accessoryView ?? contentView
        constrain(contentView, textInput, trailingBoundaryView) { contentView, textInput, trailingBoundaryView in
            textInput.top == contentView.top - 8
            textInput.bottom == contentView.bottom + 8
            textInput.trailing == trailingBoundaryView.trailing - textInputSpacing
        }

        NSLayoutConstraint.activate([
            cellNameLabel.trailingAnchor.constraint(equalTo: textInput.leadingAnchor, constant: -textInputSpacing)
        ])

    }
    
    override func setupAccessibiltyElements() {
        super.setupAccessibiltyElements()
        
        var currentElements = accessibilityElements ?? []
        if let textInput = textInput {
            currentElements.append(textInput)
        }
        accessibilityElements = currentElements
    }
    
    @objc func onCellSelected(_ sender: AnyObject!) {
        if !textInput.isFirstResponder {
            textInput.becomeFirstResponder()
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: CharacterSet.newlines) != .none {
            textField.resignFirstResponder()
            return false
        }
        else {
            return true
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textInput.text {
            descriptor?.select(SettingsPropertyValue.string(value: text))
        }
    }
}

class SettingsStaticTextTableCell: SettingsTableCell {

    override func setup() {
        super.setup()
        cellNameLabel.numberOfLines = 0
        cellNameLabel.textAlignment = .justified
    }

}
