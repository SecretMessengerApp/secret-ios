
import Foundation

class SeparatorTableViewCell: UITableViewCell, SeparatorViewProtocol, Themeable {

    let separator = UIView()
    var separatorInsetConstraint: NSLayoutConstraint!

    var separatorLeadingAnchor: NSLayoutXAxisAnchor {
        return contentView.layoutMarginsGuide.leadingAnchor
    }

    var separatorLeadingInset: CGFloat = 0 {
        didSet {
            separatorInsetConstraint?.constant = separatorLeadingInset
        }
    }

    var showSeparator: Bool {
        get { return !separator.isHidden }
        set { separator.isHidden = !newValue }
    }

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
                ? UIColor(white: 0, alpha: 0.08)
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
        separator.backgroundColor = UIColor.from(scheme: .separator, variant: colorSchemeVariant)
    }

    final func contentBackgroundColor(for colorSchemeVariant: ColorSchemeVariant) -> UIColor {
        return contentBackgroundColor ?? UIColor.dynamic(scheme: .cellBackground)
    }

}
