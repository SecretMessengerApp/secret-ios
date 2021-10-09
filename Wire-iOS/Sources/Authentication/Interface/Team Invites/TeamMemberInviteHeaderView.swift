
import UIKit

final class TeamMemberInviteHeaderView: UIView {
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let bottomSpacerView = UIView()
    private var bottomSpacerViewHeightConstraint: NSLayoutConstraint?

    var header: UIView {
        return titleLabel
    }
    
    var bottomSpacing: CGFloat = 0 {
        didSet {
            bottomSpacerViewHeightConstraint?.constant = bottomSpacing
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        subtitleLabel.font = FontSpec(.normal, .regular).font!
        stackView.axis = .vertical
        stackView.spacing = 24

        [titleLabel, subtitleLabel, bottomSpacerView].forEach(stackView.addArrangedSubview)

        [titleLabel, subtitleLabel].forEach(){
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
            $0.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        }

        titleLabel.textColor = UIColor.Team.textColor
        subtitleLabel.textColor = UIColor.Team.subtitleColor
        addSubview(stackView)

        titleLabel.text = "team.invite.header.title".localized
        subtitleLabel.text = "team.invite.header.subtitle".localized
    }
    
    func updateHeadlineLabelFont(forWidth width: CGFloat) {
        titleLabel.font = width > 320 ? AuthenticationStepController.headlineFont : AuthenticationStepController.headlineSmallFont
    }
    
    private func createConstraints() {
        [stackView, bottomSpacerView].forEach(){ $0.translatesAutoresizingMaskIntoConstraints = false }
        stackView.fitInSuperview()

        bottomSpacerViewHeightConstraint = bottomSpacerView.heightAnchor.constraint(equalToConstant: 0)
        bottomSpacerViewHeightConstraint?.priority = .fittingSizeLevel
        bottomSpacerViewHeightConstraint?.isActive = true
    }
}
