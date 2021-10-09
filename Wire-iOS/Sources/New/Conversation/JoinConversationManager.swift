

import Foundation

class JoinConversationManager {
    
    private var inviteURL: URL?
    
    init(inviteURL: URL) {
        self.inviteURL = inviteURL
    }
    
    init(inviteURLString: String) {
        self.inviteURL = URL(string: inviteURLString)
    }
    
    var isValidInviteURL: Bool {
        return inviteId != nil
    }
    
    private var inviteId: String? {
        guard let host = inviteURL?.host, (host.contains("secret.chat") || host.contains("isecret.im")) else {
            return nil
        }
//        return URLComponents(url: inviteURL, resolvingAgainstBaseURL: false)?.queryItems?.first?.value
        guard let invite = inviteURL?.lastPathComponent else { return nil}
        var inviteId = invite
        if let query = inviteURL?.query {
            inviteId = query.replacingOccurrences(of: "id=", with: "")
        }
  
        do {
            let regex = try NSRegularExpression(pattern: "[a-f,0-9]{10}", options: [])
            let results = regex.matches(
                in: inviteId, options: [],
                range: NSRange(location: 0, length: inviteId.count)
            )
            return results.isEmpty ? nil : inviteId
        } catch {
            return nil
        }
    }
    
    func checkOrPresentJoinAlert(on: UIViewController, completion: (() -> Void)? = {}) {
        guard let inviteId = inviteId else { return }
        GroupManageService.joinCheck(inviteId: inviteId) { result in
            HUD.hide()
            switch result {
            case .success(let state):
                switch state {
                case .alreadyIn(let cid):
                    HUD.text("conversation.status.group_joined".localized)
                    JoinConversationManager.selectConversationIfAvailable(cid, completion: completion)
                case .warning:
                    JoinConversationManager.presentJoinConvertionWarningAlert(on: on) {
                        JoinConversationManager.joinConversation(cid: inviteId, completion: completion)
                    }
                case .lock:
                    JoinConversationManager.presentJoinConvertionLockAlert(on: on)
                case .willIn:
                    JoinConversationManager.presentJoinConvertionAlert(on: on, inviteId: inviteId, completion: completion)
                }
            case .failure(let msg): HUD.error(msg, completion: completion)
            }
        }
    }
    
    static private func presentJoinConvertionAlert(
        on viewController: UIViewController,
        inviteId: String,
        completion: (() -> Void)? = {}
        ) {
        viewController.presentAlertWithOKCancelButton(
            message: "conversation.status.group_join".localized,
            okActionHandler: { _ in
                HUD.loading()
                JoinConversationManager.joinConversation(cid: inviteId, completion: completion)
        }) {
            completion?()
        }
    }
    
    static private func joinConversation(cid: String, completion: (() -> Void)?) {
        GroupManageService.join(id: cid) { result in
            switch result {
            case .success(let cid):
                HUD.text("conversation.status.group_join_success".localized)
                completion?()
                delay(0.3) { self.selectConversationIfAvailable(cid) }
            case .failure(let msg): HUD.error(msg, completion: completion)
            }
        }
    }
    
    private static func selectConversationIfAvailable(_ cid: String, completion: (() -> Void)? = {}) {
        if  let uuid = UUID(uuidString: cid),
            let conversation = ZMConversation(remoteID: uuid) {
            ZClientViewController.shared?.select(conversation: conversation, scrollTo: nil, focusOnView: true, animated: true, completion: completion)
        } else {
            completion?()
        }
    }
    
    private static func presentJoinConvertionWarningAlert(
        on viewController: UIViewController,
        okAction: (() -> Void)? = {}
        ) {
        let alert = UIAlertController(
            title: "conversation.group.message.illegal.hint".localized,
            message: "conversation.group.message.illegal.warning".localized,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "conversation.group.message.illegal.stilljoin".localized, style: .cancel) { (_) in
            okAction?()
        }
        okAction.setValue(UIColor.from(scheme: .textPlaceholder), forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "conversation.group.message.illegal.canceljoin".localized, style: .default) { (_) in
        }
        cancelAction.setValue(UIColor.from(scheme: .textForeground), forKey: "titleTextColor")
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static private func presentJoinConvertionLockAlert(
        on viewController: UIViewController
        ) {
        let alert = UIAlertController(
            title: "conversation.group.message.illegal.hint".localized,
            message: "conversation.group.message.illegal.lock".localized,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "conversation.group.message.illegal.know".localized, style: .default) { (_) in
        }
        okAction.setValue(UIColor.from(scheme: .textForeground), forKey: "titleTextColor")
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension JoinConversationManager {
    
    static func join(_ handleId: String, inviteId: String, completion: @escaping () -> Void) {
        GroupManageService.joinAndCompletionData(id: inviteId) { (_) in
            completion()
        }
    }
    
}
