
import UIKit

protocol GroupDetailsFooterViewDelegate: class {
    func footerView(_ view: GroupDetailsFooterView, shouldPerformAction action: GroupDetailsFooterView.Action)
}

final class GroupDetailsFooterView: ConversationDetailFooterView {
    
    weak var delegate: GroupDetailsFooterViewDelegate?
    
    enum Action {
        case more, invite
    }
    
    init() {
        super.init(mainButton: RestrictedIconButton(requiredPermissions: .member))
 
        rightButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func action(for button: IconButton) -> Action? {
        switch button {
        case rightButton: return .more
        case leftButton: return .invite
        default: return nil
        }
    }
    
    func update(for conversation: ZMConversation) {
        let selfUser = ZMUser.selfUser()!
        self.isHidden = selfUser.isGuest(in: conversation) || selfUser.teamRole == .partner || (!conversation.creator.isSelfUser && conversation.isOnlyCreatorInvite)
        leftButton.isHidden = selfUser.isGuest(in: conversation) || selfUser.teamRole == .partner
        leftButton.isEnabled = conversation.conversationType == .hugeGroup ? true : conversation.freeParticipantSlots > 0
    }
    
    override func setupButtons() {
        leftIcon = .plus
        leftButton.setTitle("participants.footer.add_title".localized(uppercased: true), for: .normal)
        leftButton.accessibilityIdentifier = "OtherUserMetaControllerLeftButton"
        rightIcon = .ellipsis
        rightButton.accessibilityIdentifier = "OtherUserMetaControllerRightButton"
    }

    override func leftButtonTapped(_ sender: IconButton) {
        delegate?.footerView(self, shouldPerformAction: .invite)
    }

    override func rightButtonTapped(_ sender: IconButton) {
        delegate?.footerView(self, shouldPerformAction: .more)
    }
    
}
