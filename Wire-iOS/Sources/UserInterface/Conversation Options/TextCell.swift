
import UIKit
import Cartography

final class TextCell: UITableViewCell, CellConfigurationConfigurable {
    
    private let container = UIView()
    private let label = CopyableLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.addSubview(container)
        container.addSubview(label)
        label.font = FontSpec(.normal, .light).font
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        constrain(contentView, container, label) { contentView, container, label in
            container.leading == contentView.leading
            container.top == contentView.top
            container.trailing == contentView.trailing
            container.bottom == contentView.bottom - 32
            label.top == container.top + 16
            label.leading == container.leading + 16
            label.trailing == container.trailing - 16
            label.bottom == container.bottom - 16
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with configuration: CellConfiguration, variant: ColorSchemeVariant) {
        guard case let .text(text) = configuration else { preconditionFailure() }
        label.attributedText = text && .lineSpacing(8)
        label.textColor = UIColor.dynamic(scheme: .title)
        container.backgroundColor = UIColor.from(scheme: .barBackground, variant: variant)
    }
    
}
