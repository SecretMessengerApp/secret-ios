
import Foundation

 final class ConversationCallController: NSObject {
    
    private unowned let target: UIViewController
    private let conversation: ZMConversation
    
    @objc init(conversation: ZMConversation, target: UIViewController) {
        self.conversation = conversation
        self.target = target
        super.init()
    }
    
    @objc func startAudioCall(started: (() -> Void)?) {
        let startCall = { [weak self] in
            guard let `self` = self else { return }
            self.conversation.confirmJoiningCallIfNeeded(alertPresenter: self.target) {
                started?()
                self.conversation.startAudioCall()
            }
        }
        
        if conversation.activeParticipants.count <= 4 {
            startCall()
        } else {
            confirmGroupCall { accepted in
                guard accepted else { return }
                startCall()
            }
        }
    }
    
    @objc func startVideoCall(started: (() -> Void)?) {
        conversation.confirmJoiningCallIfNeeded(alertPresenter: target) { [conversation] in
            started?()
            conversation.startVideoCall()
        }
    }
    
    @objc func joinCall() {
        guard conversation.canJoinCall else { return }
        conversation.confirmJoiningCallIfNeeded(alertPresenter: target) { [conversation] in
            conversation.joinCall() // This will result in joining an ongoing call.
        }
    }
    
    // MARK: - Helper

    private func confirmGroupCall(completion: @escaping (_ completion: Bool) -> ()) {
        let controller = UIAlertController.confirmGroupCall(
            participants: conversation.activeParticipants.count - 1,
            completion: completion
        )
        target.present(controller, animated: true)
    }

}
