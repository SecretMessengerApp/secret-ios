
import UIKit
import Cartography

fileprivate extension InviteResult {
    var iconType: StyleKitIcon {
        switch self {
        case .success: return .checkmark
        case .failure: return .exclamationMarkCircle
        }
    }
}

final class TeamMemberInviteTableViewCell: UITableViewCell {
    
    private let emailLabel = UILabel()
    private let errorLabel = UILabel()
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    
    var content: InviteResult? {
        didSet {
            switch content {
            case let .success(email)?:
                errorLabel.isHidden = true
                emailLabel.text = email
            case let .failure(email, error)?:
                errorLabel.isHidden = false
                emailLabel.text = email
                errorLabel.text = error.errorDescription
            default: break
            }
            
            content.apply {
                iconImageView.setIcon($0.iconType, size: .tiny, color: UIColor.Team.inactiveButton)
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        stackView.axis = .vertical
        emailLabel.font = FontSpec(.normal, .regular).font!
        emailLabel.textColor = UIColor.Team.subtitleColor
        errorLabel.font = FontSpec(.small, .regular).font!
        errorLabel.textColor = UIColor.from(scheme: .errorIndicator, variant: .light)
        backgroundColor = .clear
        contentView.addSubview(stackView)
        [emailLabel, errorLabel].forEach(stackView.addArrangedSubview)
        stackView.spacing = 2
        contentView.addSubview(iconImageView)
    }
    
    private func createConstraints() {
        constrain(contentView, stackView, iconImageView) { contentView, stackView, iconImageView in
            stackView.leading == contentView.leading + 24
            stackView.centerY == contentView.centerY
            stackView.trailing <= iconImageView.leading - 8
            iconImageView.centerY == contentView.centerY
            iconImageView.trailing == contentView.trailing - 24
        }
    }
}
