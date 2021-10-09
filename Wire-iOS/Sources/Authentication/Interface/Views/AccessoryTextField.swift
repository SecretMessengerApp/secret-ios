
import Foundation

protocol TextFieldValidationDelegate: class {

    /// Delegate for validation. It is called when every time .editingChanged event fires
    ///
    /// - Parameters:
    ///   - sender: the sender is the textfield needs to validate
    ///   - error: An error object that indicates why the request failed, or nil if the request was successful.
    func validationUpdated(sender: UITextField, error: TextFieldValidator.ValidationError?)
}

class AccessoryTextField: UITextField, TextContainer, Themeable {
    enum Kind: Equatable {
        case email
        case name(isTeam: Bool)
        case password(isNew: Bool)
        case phoneNumber
        case unknown
    }

    let textFieldValidator: TextFieldValidator
    public weak var textFieldValidationDelegate: TextFieldValidationDelegate?

    // MARK: - UI constants

    static let enteredTextFont = FontSpec(.normal, .regular, .inputText).font!
    static let placeholderFont = FontSpec(.small, .regular).font!
    static let ConfirmButtonWidth: CGFloat = 32
    static let GuidanceDotWidth: CGFloat = 8

    var isLoading = false {
        didSet {
            updateLoadingState()
        }
    }
    
    var kind: Kind {
        didSet {
            setupTextFieldProperties()
        }
    }
    
    var overrideButtonIcon: StyleKitIcon? {
        didSet {
            updateButtonIcon()
        }
    }

    var input: String {
        return text ?? ""
    }

    /// Whether to display the confirm button.
    var showConfirmButton: Bool = true {
        didSet {
            confirmButton.isHidden = !showConfirmButton
        }
    }

    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = .light {
        didSet {
            applyColorScheme(colorSchemeVariant)
        }
    }

    /// The other text field that needs to be valid in order to enable the confirm button.
    private weak var boundTextField: AccessoryTextField?

    /**
     * Binds the state of the confirmation button to the validity of another text field.
     * The button will be enabled when both the current and bound fields are valid.
     */

    func bindConfirmationButton(to textField: AccessoryTextField) {
        assert(boundTextField == nil, "A text field cannot be bound to another text field more than once.")
        self.boundTextField = textField
        textField.boundTextField = self
    }

    var enableConfirmButton: (() -> Bool)?

    let confirmButton: IconButton = {
        let iconButton = IconButton(style: .circular, variant: .dark)
        iconButton.accessibilityIdentifier = "ConfirmButton"
        iconButton.accessibilityLabel = "general.next".localized
        iconButton.isEnabled = false
        return iconButton
    }()

    let guidanceDot: RoundedView = {
        let indicator = RoundedView()
        indicator.shape = .circle
        indicator.isHidden = true
        return indicator
    }()

    let accessoryStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    let accessoryContainer = UIView()

    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    let placeholderInsets: UIEdgeInsets

    convenience override init(frame: CGRect) {
        self.init(kind: .unknown, leftInset: 8)
    }

    /// Init with kind for keyboard style and validator type. Default is .unknown
    ///
    /// - Parameter kind: the type of text field
    init(kind: Kind = .unknown, leftInset: CGFloat = 8) {
        var topInset: CGFloat = 0
        if #available(iOS 11, *) {
            topInset = 0
        } else {
            /// Placeholder frame calculation is changed in iOS 11, therefore the TOP inset is not necessary
            topInset = 8
        }

        placeholderInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: 0, right: 16)
        textFieldValidator = TextFieldValidator()

        self.kind = kind

        super.init(frame: .zero)
        self.setupTextFieldProperties()

        self.rightView = accessoryContainer
        self.rightViewMode = .always

        self.font = AccessoryTextField.enteredTextFont
        self.textColor = .dynamic(scheme: .title)

        autocorrectionType = .no
        contentVerticalAlignment = .center
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            layer.cornerRadius = 4
        default:
            break
        }
        layer.masksToBounds = true
        backgroundColor = UIColor.Team.textfieldColor

        setup()
        setupTextFieldProperties()
        updateButtonIcon()
        applyColorScheme(colorSchemeVariant)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 56)
    }

    private func setupTextFieldProperties() {
        self.returnKeyType = .next

        switch kind {
        case .email:
            keyboardType = .emailAddress
            autocorrectionType = .no
            autocapitalizationType = .none
            accessibilityIdentifier = "EmailField"
            textContentType = .emailAddress
        case .password(let isNew):
            isSecureTextEntry = true
            accessibilityIdentifier = "PasswordField"
            autocapitalizationType = .none
            if #available(iOS 12, *) {
                textContentType = isNew ? .newPassword : .password
                passwordRules = textFieldValidator.passwordRules
            }
        case .name(let isTeam):
            autocapitalizationType = .words
            accessibilityIdentifier = "NameField"
            textContentType = isTeam ? .organizationName : .name
        case .phoneNumber:
            textContentType = .telephoneNumber
            keyboardType = .numberPad
            accessibilityIdentifier = "PhoneNumberField"
        case .unknown:
            keyboardType = .asciiCapable
            textContentType = nil
        }
    }

    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        guidanceDot.backgroundColor = UIColor.from(scheme: .errorIndicator, variant: colorSchemeVariant)
    }
    
    private func updateLoadingState() {
        updateButtonIcon()
        let animationKey = "rotation_animation"
        if isLoading {
            let animation = CABasicAnimation(rotationSpeed: 1.4, beginTime: 0)
            confirmButton.layer.add(animation, forKey: animationKey)
        } else {
            confirmButton.layer.removeAnimation(forKey: animationKey)
        }
    }
    
    private var buttonIcon: StyleKitIcon {
        return isLoading
        ? .spinner
        : overrideButtonIcon ?? (UIApplication.isLeftToRightLayout ? .forwardArrow : .backArrow)
    }
    
    private var iconSize: StyleKitIcon.Size {
        return isLoading ? .medium : .tiny
    }
    
    private func updateButtonIcon() {
        confirmButton.setIcon(buttonIcon, size: iconSize, for: .normal)
        
        if isLoading {
            confirmButton.setIconColor(UIColor.Team.inactiveButtonColor, for: .normal)
            confirmButton.setBackgroundImageColor(.clear, for: .normal)
            confirmButton.setBackgroundImageColor(.clear, for: .disabled)
        } else {
            confirmButton.setIconColor(UIColor.Team.textfieldColor, for: .normal)
            confirmButton.setIconColor(UIColor.Team.textfieldColor, for: .disabled)
            confirmButton.setBackgroundImageColor(UIColor.Team.activeButtonColor, for: .normal)
            confirmButton.setBackgroundImageColor(UIColor.Team.inactiveButtonColor, for: .disabled)
        }

        confirmButton.adjustsImageWhenDisabled = false
    }

    private func setup() {
        accessoryStack.addArrangedSubview(guidanceDot)
        accessoryStack.addArrangedSubview(confirmButton)

        self.confirmButton.addTarget(self, action: #selector(confirmButtonTapped(button:)), for: .touchUpInside)
        self.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)

        accessoryStack.translatesAutoresizingMaskIntoConstraints = false
        accessoryContainer.translatesAutoresizingMaskIntoConstraints = false
        accessoryContainer.addSubview(accessoryStack)

        NSLayoutConstraint.activate([
            // dimensions
            confirmButton.widthAnchor.constraint(equalToConstant: AccessoryTextField.ConfirmButtonWidth),
            confirmButton.heightAnchor.constraint(equalToConstant: AccessoryTextField.ConfirmButtonWidth),
            guidanceDot.widthAnchor.constraint(equalToConstant: AccessoryTextField.GuidanceDotWidth),
            guidanceDot.heightAnchor.constraint(equalToConstant: AccessoryTextField.GuidanceDotWidth),

            // spacing
            accessoryStack.topAnchor.constraint(equalTo: accessoryContainer.topAnchor),
            accessoryStack.bottomAnchor.constraint(equalTo: accessoryContainer.bottomAnchor),
            accessoryStack.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor, constant: 0),
            accessoryStack.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - custom edge insets

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let textRect = super.textRect(forBounds: bounds)

        return textRect.inset(by: textInsets.directionAwareInsets)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let editingRect: CGRect = super.editingRect(forBounds: bounds)
        return editingRect.inset(by: textInsets.directionAwareInsets)
    }

    @objc func textFieldDidChange(textField: UITextField) {
        updateText(input)
    }

    /// Whether the input is valid.
    var isInputValid: Bool {
        return enableConfirmButton?() ?? !input.isEmpty
    }

    func updateText(_ text: String) {
        self.text = text
        validateInput()
        boundTextField?.validateInput()
    }

    private func updateConfirmButton() {
        if let boundTextField = self.boundTextField {
            confirmButton.isEnabled = boundTextField.isInputValid && self.isInputValid
        } else {
            confirmButton.isEnabled = isInputValid
        }
    }

    // MARK: - text validation

    @objc func confirmButtonTapped(button: UIButton) {
        validateInput()
    }

    func validateInput() {
        let error = textFieldValidator.validate(text: text, kind: kind)
        textFieldValidationDelegate?.validationUpdated(sender: self, error: error)
        updateConfirmButton()
    }

    func showGuidanceDot() {
        guidanceDot.isHidden = false
    }

    func hideGuidanceDot() {
        guidanceDot.isHidden = true
    }

    // MARK: - placeholder

    func attributedPlaceholderString(placeholder: String) -> NSAttributedString {
        let attribute: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.Team.placeholderColor,
                                        .font: AccessoryTextField.placeholderFont]
        return placeholder && attribute
    }

    override open var placeholder: String? {
        set {
            if let newValue = newValue {
                attributedPlaceholder = attributedPlaceholderString(placeholder: newValue)
            }
        }
        get {
            return super.placeholder
        }
    }

    override func drawPlaceholder(in rect: CGRect) {
        super.drawPlaceholder(in: rect.inset(by: placeholderInsets.directionAwareInsets))
    }

    // MARK: - right and left accessory

    func rightAccessoryViewRect(forBounds bounds: CGRect, leftToRight: Bool) -> CGRect {
        let contentSize = accessoryContainer.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        var rightViewRect: CGRect
        let newY = bounds.origin.y + (bounds.size.height -  contentSize.height) / 2

        if leftToRight {
            rightViewRect = CGRect(x: CGFloat(bounds.maxX - contentSize.width), y: newY, width: contentSize.width, height: contentSize.height)
        } else {
            rightViewRect = CGRect(x: bounds.origin.x, y: newY, width: contentSize.width, height: contentSize.height)
        }

        return rightViewRect
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftToRight: Bool = UIApplication.isLeftToRightLayout
        if leftToRight {
            return rightAccessoryViewRect(forBounds: bounds, leftToRight: leftToRight)
        } else {
            return .zero
        }
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let leftToRight: Bool = UIApplication.isLeftToRightLayout
        if leftToRight {
            return .zero
        } else {
            return rightAccessoryViewRect(forBounds: bounds, leftToRight: leftToRight)
        }
    }
}
