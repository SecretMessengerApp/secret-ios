
import Foundation

protocol IncomingRequestFooterViewDelegate: class {

    /// Called when the user accepts or denies a connection request.
    func footerView(_ footerView: IncomingRequestFooterView, didRespondToRequestWithAction action: IncomingConnectionAction)

}

/**
 * A view that lets the user accept a connection request.
 */

class IncomingRequestFooterView: UIView, Themeable {

    let titleLabel = UILabel()
    let acceptButton = Button()
    let ignoreButton = Button()

    let contentStack = UIStackView()

    /// The delegate of the view, that will be called when the user accepts or denies the request.
    weak var delegate: IncomingRequestFooterViewDelegate?

    /// The color scheme variant.
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            if colorSchemeVariant != oldValue {
                applyColorScheme(colorSchemeVariant)
            }
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        configureConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        configureConstraints()
    }

    private func configureSubviews() {
        titleLabel.text = "connection_request_pending_title".localized(uppercased: true)
        titleLabel.font = .smallSemiboldFont
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        acceptButton.accessibilityIdentifier = "accept"
        acceptButton.setTitle("inbox.connection_request.connect_button_title".localized(uppercased: true), for: .normal)
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        acceptButton.layer.cornerRadius = 8
        acceptButton.titleLabel?.font = .smallSemiboldFont

        ignoreButton.accessibilityIdentifier = "ignore"
        ignoreButton.setTitle("inbox.connection_request.ignore_button_title".localized(uppercased: true), for: .normal)
        ignoreButton.addTarget(self, action: #selector(ignoreButtonTapped), for: .touchUpInside)
        ignoreButton.layer.cornerRadius = 8
        ignoreButton.titleLabel?.font = .smallSemiboldFont

        let buttonsStack = UIStackView(arrangedSubviews: [ignoreButton, acceptButton])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = 16
        buttonsStack.alignment = .fill
        buttonsStack.distribution = .fillEqually

        contentStack.axis = .vertical
        contentStack.alignment = .fill
        contentStack.spacing = 24
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(buttonsStack)
        addSubview(contentStack)

        colorSchemeVariant = ColorScheme.default.variant
        applyColorScheme(colorSchemeVariant)
    }

    private func configureConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // buttons
            ignoreButton.heightAnchor.constraint(equalToConstant: 48),
            acceptButton.heightAnchor.constraint(equalToConstant: 48),

            // contentStack
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Theme

    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        titleLabel.textColor = .dynamic(scheme: .subtitle)
        backgroundColor = UIColor.from(scheme: .contentBackground, variant: colorSchemeVariant)

        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.setTitleColor(.whiteAlpha40, for: .highlighted)
        acceptButton.setBackgroundImageColor(UIColor.accent(), for: .normal)
        acceptButton.setBackgroundImageColor(UIColor.accentDarken, for: .highlighted)

        ignoreButton.setTitleColor(UIColor.dynamic(scheme: .title), for: .normal)
        ignoreButton.setTitleColor(UIColor.from(scheme: .textDimmed, variant: colorSchemeVariant), for: .highlighted)
        ignoreButton.setBackgroundImageColor(UIColor.from(scheme: .secondaryAction, variant: colorSchemeVariant), for: .normal)
        ignoreButton.setBackgroundImageColor(UIColor.from(scheme: .secondaryActionDimmed, variant: colorSchemeVariant), for: .highlighted)
    }

    // MARK: - Events

    @objc private func acceptButtonTapped() {
        delegate?.footerView(self, didRespondToRequestWithAction: .accept)
    }

    @objc private func ignoreButtonTapped() {
        delegate?.footerView(self, didRespondToRequestWithAction: .ignore)
    }

}
