
import UIKit

class SeparatorCollectionViewCell: UICollectionViewCell, SeparatorViewProtocol, Themeable {

    let separator = UIView()
    var separatorInsetConstraint: NSLayoutConstraint!

    var separatorLeadingInset: CGFloat = 24 {
        didSet {
            separatorInsetConstraint?.constant = separatorLeadingInset
        }
    }

    var showSeparator: Bool {
        get { return !separator.isHidden }
        set { separator.isHidden = !newValue }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
    }

    private func configureSubviews() {

        setUp()

        separator.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(separator)

        createSeparatorConstraints()

        applyColorScheme(ColorScheme.default.variant)
    }

    func setUp() {
        // can be overriden to customize interface
    }

    // MARK: - Themable

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? UIColor.dynamic(scheme: .cellSelectedBackground)
                : contentBackgroundColor(for: colorSchemeVariant)
        }
    }

    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }

    // if nil the background color is the default content background color for the theme
    @objc dynamic var contentBackgroundColor: UIColor? = nil {
        didSet {
            guard oldValue != contentBackgroundColor else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }

    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        separator.backgroundColor = .dynamic(scheme: .separator)
    }

    final func contentBackgroundColor(for colorSchemeVariant: ColorSchemeVariant) -> UIColor {
        return contentBackgroundColor ?? .dynamic(scheme: .barBackground)
    }

}
