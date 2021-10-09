
import Foundation

extension ConversationContentViewController {
    
    func updateTableViewHeaderView() {

        // Don't display the conversation header if the message window doesn't include the first message and it is not a connection
        guard
            let userSession = ZMUserSession.shared(),
            !dataSource.hasOlderMessagesToLoad
            else { return }

        var headerView: UIView? = nil

        let otherParticipant: ZMUser?
        if conversation.conversationType == .connection {
            otherParticipant = conversation.firstActiveParticipantOtherThanSelf ?? conversation.connectedUser
        } else {
            otherParticipant = conversation.firstActiveParticipantOtherThanSelf
        }

        let connectionOrOneOnOne = [.connection, .oneOnOne].contains(conversation.conversationType)

        if connectionOrOneOnOne, let otherParticipant = otherParticipant {
            connectionViewController = UserConnectionViewController(userSession: userSession, user: otherParticipant)
            headerView = connectionViewController?.view
        } else {
            headerView = GroupHeaderView(conversation: conversation)
        }

        if let headerView = headerView {
            headerView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            setConversationHeaderView(headerView)
        } else {
            tableView.tableHeaderView = nil
        }
    }
}


private class GroupHeaderView: UIView {
    
    init(conversation: ZMConversation) {
        super.init(frame: .zero)

        guard let avatar = conversation.avatarView else { return }
        addSubview(avatar)
        let encryptedLabel = EncryptedInfoLabel.create()
        addSubview(encryptedLabel)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatar.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatar.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
            avatar.widthAnchor.constraint(equalToConstant: 264),
            avatar.heightAnchor.constraint(equalToConstant: 264)
        ])
        
        NSLayoutConstraint.activate([
            encryptedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            encryptedLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 32),
            encryptedLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -32),
            encryptedLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 10)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
