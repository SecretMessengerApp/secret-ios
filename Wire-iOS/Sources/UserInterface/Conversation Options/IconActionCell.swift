
import UIKit
import Cartography

final class IconActionCell: UITableViewCell, CellConfigurationConfigurable {
    
    private let separator = UIView()
    private let imageContainer = UIView()
    private let iconImageView = UIImageView()
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .init(white: 0, alpha: 0.08)
        selectedBackgroundView = backgroundView
        backgroundColor = .clear
        imageContainer.addSubview(iconImageView)
        label.font = FontSpec(.normal, .light).font
        [imageContainer, label, separator].forEach(contentView.addSubview)
    }
    
    private func createConstraints() {
        constrain(contentView, label, separator, imageContainer, iconImageView) { contentView, label, separator, imageContainer, imageView in
            imageContainer.top == contentView.top
            imageContainer.bottom == contentView.bottom
            imageContainer.leading == contentView.leading
            imageContainer.width == 64
            imageView.center == imageContainer.center
            
            label.leading == imageContainer.trailing
            label.top == contentView.top
            label.trailing == contentView.trailing
            label.bottom == contentView.bottom
            label.height == 56
            
            separator.height == .hairline
            separator.leading == label.leading
            separator.trailing == label.trailing
            separator.bottom == contentView.bottom
        }
    }
    
    func configure(with configuration: CellConfiguration, variant: ColorSchemeVariant) {
        guard case let .iconAction(title, icon, color, _) = configuration else { preconditionFailure() }
        let mainColor = color ?? UIColor.dynamic(scheme: .title)
        iconImageView.setIcon(icon, size: .tiny, color: mainColor)
        label.textColor = mainColor
        label.text = title
        separator.backgroundColor = UIColor.from(scheme: .cellSeparator, variant: variant)
    }
}

