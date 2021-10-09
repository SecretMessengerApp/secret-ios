
import UIKit

class SenderNameCellComponent: UIView {

    let label = UILabel()
    let indicatorView = UIImageView()
    private var indicatorImageViewTrailing: NSLayoutConstraint!

    var senderName: String? {
        get { return label.text }
        set { label.text = newValue }
    }

    var indicatorIcon: UIImage? {
        get { return indicatorView.image }
        set { indicatorView.image = newValue }
    }

    var indicatorLabel: String? {
        get {
            return indicatorView.accessibilityLabel
        }
        set {
            indicatorView.accessibilityLabel = newValue
            indicatorView.isAccessibilityElement = newValue != nil
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
        label.accessibilityIdentifier = "author.name"
        label.numberOfLines = 1
        addSubview(label)
        addSubview(indicatorView)
    }

    private func configureConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false

        indicatorImageViewTrailing = indicatorView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -conversationHorizontalMargins.right)

        NSLayoutConstraint.activate([
            // indicatorView
            indicatorImageViewTrailing,
            indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),

            // label
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.trailingAnchor.constraint(equalTo: indicatorView.leadingAnchor, constant: -8)
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        indicatorImageViewTrailing.constant = -conversationHorizontalMargins.right
    }

}
