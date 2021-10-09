
import UIKit

/**
 * A footer view to use to display a bar of actions to perform for a conversation.
 */

class ConversationDetailFooterView: UIView {
    
    private let variant: ColorSchemeVariant
    let rightButton = IconButton()
    var leftButton: IconButton
    private let containerView = UIView()
    private var hiddenHeightConstraint: NSLayoutConstraint?
    var leftIcon: StyleKitIcon? {
        get {
            return leftButton.icon(for: .normal)
        }
        set {
            leftButton.isHidden = (newValue == .none)
            if newValue != .none {
                leftButton.setIcon(newValue, size: .tiny, for: .normal)
            }
        }
    }
    
    var rightIcon: StyleKitIcon? {
        get {
            return rightButton.icon(for: .normal)
        }
        set {
            rightButton.isHidden = (newValue == .none)
            if newValue != .none {
                rightButton.setIcon(newValue, size: .tiny, for: .normal)
            }
        }
    }
    
    override init(frame: CGRect) {
        self.variant = ColorScheme.default.variant
        self.leftButton = IconButton()
        super.init(frame: frame)
        setupViews()
        createConstraints()
    }
        
    internal init(mainButton: IconButton = IconButton()) {
        self.variant = ColorScheme.default.variant
        self.leftButton = mainButton
        super.init(frame: .zero)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let configureButton = { (button: IconButton) in
            self.containerView.addSubview(button)
            button.setIconColor(UIColor.dynamic(scheme: .iconNormal), for: .normal)
            button.setIconColor(UIColor.from(scheme: .iconHighlighted), for: .highlighted)
            button.setIconColor(UIColor.from(scheme: .buttonFaded), for: .disabled)
            button.setTitleColor(UIColor.dynamic(scheme: .iconNormal), for: .normal)
            button.setTitleColor(UIColor.from(scheme: .textDimmed), for: .highlighted)
            button.setTitleColor(UIColor.from(scheme: .buttonFaded), for: .disabled)
        }

        configureButton(leftButton)
        configureButton(rightButton)

        leftButton.setTitleImageSpacing(16)
        leftButton.titleLabel?.font = FontSpec(.small, .regular).font
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)

        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)

        backgroundColor = UIColor.dynamic(scheme: .barBackground)
        addSubview(containerView)
        
        setupButtons()
    }
    
    private func createConstraints() {
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: containerView.topAnchor),

            // containerView
            containerView.heightAnchor.constraint(equalToConstant: 56),
            containerView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: safeBottomAnchor),

            // leftButton
            leftButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),

            // leftButton
            rightButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            rightButton.leadingAnchor.constraint(greaterThanOrEqualTo: leftButton.leadingAnchor, constant: 16)
        ])
        
        // Adaptive Constraints
        hiddenHeightConstraint  = heightAnchor.constraint(equalToConstant: 0)
    }

    // MARK: - Events
    
    func setupButtons() {
        fatal("Should be overridden in subclasses")
    }
    
    @objc func leftButtonTapped(_ sender: IconButton) {
        fatal("Should be overridden in subclasses")
    }

    @objc func rightButtonTapped(_ sender: IconButton) {
        fatal("Should be overridden in subclasses")
    }
    
    override var isHidden: Bool{
        didSet {
            hiddenHeightConstraint?.isActive = isHidden
        }
    }

}
