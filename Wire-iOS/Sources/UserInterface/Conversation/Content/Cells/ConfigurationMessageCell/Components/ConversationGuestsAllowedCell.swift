
import Foundation

class GuestsAllowedCellDescription: ConversationMessageCellDescription {
    
    typealias View = GuestsAllowedCell
    let configuration: View.Configuration
    
    weak var message: ZMConversationMessage?
    weak var delegate: ConversationMessageCellDelegate?
    weak var actionController: ConversationMessageActionController?
    
    var showEphemeralTimer: Bool = false
    var topMargin: Float = 16
    
    let isFullWidth: Bool = false
    let supportsActions: Bool = false
    let containsHighlightableContent: Bool = false
    
    let accessibilityIdentifier: String? = nil
    let accessibilityLabel: String? = nil
    
    init() {
        configuration = View.Configuration()
        actionController = nil
    }
    
    init(configuration: View.Configuration) {
        self.configuration = configuration
    }
    
}

class GuestsAllowedCell: UIView, ConversationMessageCell {
    
    struct GuestsAllowedCellConfiguration { }
    
    typealias Configuration = GuestsAllowedCellConfiguration
    
    weak var delegate: ConversationMessageCellDelegate? = nil
    weak var message: ZMConversationMessage? = nil
    
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    let inviteButton = InviteButton()
    var isSelected: Bool = false
        
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func configure(with object: GuestsAllowedCellConfiguration, animated: Bool) {
        
    }
    
    @objc private func inviteButtonTapped(_ sender: UIButton) {
        delegate?.conversationMessageWantsToOpenGuestOptionsFromView(self, sourceView: self)
    }
    
}
