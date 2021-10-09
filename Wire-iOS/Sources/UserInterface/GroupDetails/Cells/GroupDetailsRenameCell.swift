

import Foundation

class GroupDetailsRenameCell : UICollectionViewCell {
 
    let headImgView = UIImageView()
    let participantsLabel = UILabel()

    let verifiedIconView = UIImageView()
    let accessoryIconView = ThemedImageView()
    let titleTextField = SimpleTextField()
    var contentStackView: UIStackView!
    
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
        
        participantsLabel.font = FontSpec.init(.small, .light).font!
        participantsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headImgView.image = UIImage.init(named: "conversation_groupPlacehold")
        headImgView.translatesAutoresizingMaskIntoConstraints = false
        headImgView.contentMode = .scaleAspectFill
        headImgView.layer.cornerRadius = 24
        headImgView.layer.masksToBounds = true
        
        verifiedIconView.image = WireStyleKit.imageOfShieldverified
        verifiedIconView.translatesAutoresizingMaskIntoConstraints = false
        verifiedIconView.contentMode = .scaleAspectFit
        verifiedIconView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        verifiedIconView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        verifiedIconView.accessibilityIdentifier = "img.shield"
        accessoryIconView.image = StyleKitIcon.pencil.makeImage(size: .like, color: .dynamic(scheme: .iconNormal))
        accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconView.contentMode = .scaleAspectFit
        accessoryIconView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        accessoryIconView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.font = FontSpec.init(.normal, .light).font!
        titleTextField.returnKeyType = .done
        titleTextField.backgroundColor = .clear
        titleTextField.textInsets = UIEdgeInsets.zero

        contentStackView = UIStackView(arrangedSubviews: [verifiedIconView, titleTextField, accessoryIconView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(headImgView)
        contentView.addSubview(participantsLabel)
        contentView.addSubview(contentStackView)
        
        let constraints = [
            headImgView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 24),
            headImgView.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            headImgView.widthAnchor.constraint(equalToConstant: 48),
            headImgView.heightAnchor.constraint(equalToConstant: 48),
            contentStackView.leadingAnchor.constraint(equalTo: headImgView.trailingAnchor, constant: 24),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStackView.heightAnchor.constraint(equalToConstant: 16),
            participantsLabel.topAnchor.constraint(equalTo: contentStackView.bottomAnchor, constant: 4),
            participantsLabel.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        contentStackView.spacing = 8
        
        configureColors()
    }
    
    func configure(for conversation: ZMConversation, editable: Bool) {
        titleTextField.text = conversation.displayName
        verifiedIconView.isHidden = conversation.securityLevel != .secure

        if let data = conversation.avatarData(size: .preview) {
            headImgView.image = UIImage(data: data)
        }
        if conversation.showMemsum || conversation.creator.isSelfUser {
            participantsLabel.text = "\(conversation.membersCount)" + " person"
        }
        if !conversation.creator.isSelfUser {
            accessoryIconView.isHidden = true
            titleTextField.isUserInteractionEnabled = false
        } else {
            titleTextField.isUserInteractionEnabled = editable
            accessoryIconView.isHidden = !editable
        }
    }
    
    private func configureColors() {
        backgroundColor = .dynamic(scheme: .cellBackground)
        accessoryIconView.image = StyleKitIcon.pencil.makeImage(size: .like, color: .dynamic(scheme: .accessory))
        titleTextField.textColor = .dynamic(scheme: .title)
        participantsLabel.textColor = .dynamic(scheme: .subtitle)
    }
}
