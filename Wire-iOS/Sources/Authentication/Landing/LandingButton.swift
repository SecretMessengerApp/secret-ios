
import UIKit

class LandingButton: UIView {
    var priorState: UIControl.State?

    let contentStack = UIStackView()
    let iconButton = IconButton(style: .circular, variant: .dark)
    let subtitleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        createConstraints()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(title: NSAttributedString, icon: StyleKitIcon, iconBackgroundColor: UIColor) {
        self.init(frame: .zero)
        accessibilityLabel = title.string
        subtitleLabel.attributedText = title
        iconButton.setIcon(icon, size: 32, for: .normal)
        iconButton.setBackgroundImageColor(iconBackgroundColor, for: .normal)
    }

    private func configureSubviews() {
        isAccessibilityElement = true
        accessibilityTraits.insert(.button)

        // contentStack
        contentStack.axis = .vertical
        contentStack.spacing = 8
        contentStack.alignment = .center
        addSubview(contentStack)

        // iconButton
        iconButton.setIconColor(.white, for: .normal)
        iconButton.setIconColor(.white, for: .selected)
        iconButton.setIconColor(.white, for: .highlighted)
        iconButton.setContentCompressionResistancePriority(.required, for: .vertical)
        contentStack.addArrangedSubview(iconButton)

        // subtitleLabel
        subtitleLabel.numberOfLines = 0
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentStack.addArrangedSubview(subtitleLabel)
    }

    private func createConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // iconButton
            iconButton.widthAnchor.constraint(equalToConstant: 72),
            iconButton.heightAnchor.constraint(equalToConstant: 72),

            // subtitleLabel
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    // MARK: - Event Forwarding

    override func accessibilityActivate() -> Bool {
        iconButton.sendActions(for: .touchUpInside)
        return true
    }

    func addTapTarget(_ target: Any, action: Selector) {
        iconButton.addTarget(target, action: action, for: .touchUpInside)
    }

}

