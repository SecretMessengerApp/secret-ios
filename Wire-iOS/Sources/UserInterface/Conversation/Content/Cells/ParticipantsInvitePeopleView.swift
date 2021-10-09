
import Foundation

protocol ParticipantsInvitePeopleViewDelegate: class {
    func invitePeopleViewInviteButtonTapped(_ invitePeopleView: ParticipantsInvitePeopleView)
}

final class ParticipantsInvitePeopleView: UIView {
    
    weak var delegate: ParticipantsInvitePeopleViewDelegate?
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    let inviteButton = InviteButton()
    
    init() {
        super.init(frame: .zero)
        setupViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        addSubview(stackView)
        [titleLabel, inviteButton].forEach(stackView.addArrangedSubview)
        titleLabel.numberOfLines = 0
        titleLabel.text = "content.system.conversation.invite.title".localized
        titleLabel.textColor = UIColor.dynamic(scheme: .title)
        titleLabel.font = FontSpec(.medium, .none).font
        
        inviteButton.setTitle("content.system.conversation.invite.button".localized, for: .normal)
        inviteButton.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
    }
    
    private func createConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc private func inviteButtonTapped(_ sender: UIButton) {
        delegate?.invitePeopleViewInviteButtonTapped(self)
    }
}
