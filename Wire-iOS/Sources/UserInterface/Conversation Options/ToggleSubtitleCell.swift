
import UIKit
import Cartography

final class ToggleSubtitleCell: UITableViewCell, CellConfigurationConfigurable {
    private let topContainer = UIView()
    private let titleLabel = UILabel()
    private let toggle = UISwitch()
    private let subtitleLabel = UILabel()
    private var action: ((Bool) -> Void)?
    private var variant: ColorSchemeVariant = .light {
        didSet {
            styleViews()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        createConstraints()
        styleViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [titleLabel, toggle].forEach(topContainer.addSubview)
        [topContainer, subtitleLabel].forEach(contentView.addSubview)
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = FontSpec(.medium, .regular).font
        titleLabel.font = FontSpec(.normal, .light).font
        titleLabel.accessibilityIdentifier = "label.guestoptions.description"
        accessibilityElements = [titleLabel, toggle]
    }
    
    private func createConstraints() {
        constrain(topContainer, titleLabel, toggle) { topContainer, titleLabel, toggle in
            toggle.centerY == topContainer.centerY
            toggle.trailing == topContainer.trailing - 16
            titleLabel.centerY == topContainer.centerY
            titleLabel.leading == topContainer.leading + 16
        }
        constrain(contentView, topContainer, subtitleLabel) { contentView, topContainer, subtitleLabel in
            topContainer.top == contentView.top
            topContainer.leading == contentView.leading
            topContainer.trailing == contentView.trailing
            topContainer.height == 56
            
            subtitleLabel.leading == contentView.leading + 16
            subtitleLabel.trailing == contentView.trailing - 16
            subtitleLabel.top == topContainer.bottom + 16
            subtitleLabel.bottom == contentView.bottom - 24
        }
    }
    
    private func styleViews() {
        topContainer.backgroundColor = UIColor.from(scheme: .barBackground, variant: variant)
        titleLabel.textColor = UIColor.dynamic(scheme: .title)
        subtitleLabel.textColor = UIColor.from(scheme: .textDimmed, variant: variant)
        backgroundColor = .clear
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        action?(sender.isOn)
    }
    
    func configure(with configuration: CellConfiguration, variant: ColorSchemeVariant) {
        guard case let .toggle(title, subtitle, identifier, get, set) = configuration else { preconditionFailure() }
        titleLabel.text = title
        subtitleLabel.text = subtitle
        action = set
        toggle.accessibilityIdentifier = identifier
        toggle.isOn = get()
        self.variant = variant
    }
}
