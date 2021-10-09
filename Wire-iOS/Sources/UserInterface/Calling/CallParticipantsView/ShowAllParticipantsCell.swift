
import Foundation

class ShowAllParticipantsCell: SeparatorCollectionViewCell {
    
    let participantIconView = ThemedImageView()
    let titleLabel = UILabel()
    let accessoryIconView = ThemedImageView()
    var contentStackView : UIStackView!
    
    var variant : ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != variant else { return }
            configureColors()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        accessibilityIdentifier = "cell.call.show_all_participants"
        participantIconView.translatesAutoresizingMaskIntoConstraints = false
        participantIconView.contentMode = .scaleAspectFit
        participantIconView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        
        accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconView.contentMode = .center
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = FontSpec.init(.normal, .light).font!
        
        let avatarSpacer = UIView()
        avatarSpacer.addSubview(participantIconView)
        avatarSpacer.translatesAutoresizingMaskIntoConstraints = false
        avatarSpacer.widthAnchor.constraint(equalToConstant: 64).isActive = true
        avatarSpacer.heightAnchor.constraint(equalTo: participantIconView.heightAnchor).isActive = true
        avatarSpacer.centerXAnchor.constraint(equalTo: participantIconView.centerXAnchor).isActive = true
        avatarSpacer.centerYAnchor.constraint(equalTo: participantIconView.centerYAnchor).isActive = true
        
        let iconViewSpacer = UIView()
        iconViewSpacer.translatesAutoresizingMaskIntoConstraints = false
        iconViewSpacer.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        contentStackView = UIStackView(arrangedSubviews: [avatarSpacer, titleLabel, iconViewSpacer, accessoryIconView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(contentStackView)
        contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        
        configureColors()
    }
    
    private func configureColors() {
        participantIconView.setIcon(.person, size: .tiny, color: .dynamic(scheme: .iconNormal))
        accessoryIconView.setIcon(.disclosureIndicator, size: .like, color: .dynamic(scheme: .accessory))
        titleLabel.textColor = .dynamic(scheme: .title)
    }
}

extension ShowAllParticipantsCell: CallParticipantsCellConfigurationConfigurable {
    func configure(with configuration: CallParticipantsCellConfiguration, variant: ColorSchemeVariant) {
        guard case let .showAll(totalCount: totalCount) = configuration else { preconditionFailure() }
        
        self.variant = variant
        titleLabel.text = "call.participants.show_all".localized(args: String(totalCount))
    }
}

extension ShowAllParticipantsCell: ParticipantsCellConfigurable {
    func configure(with rowType: ParticipantsRowType, conversation: ZMConversation, showSeparator: Bool) {
        guard case let .showAll(count) = rowType else { preconditionFailure() }
        if count == 0 {

            titleLabel.text = "call.participants.show_all_without_count".localized
        } else {
            titleLabel.text = "call.participants.show_all".localized(args: String(count))
        }
    }
}
