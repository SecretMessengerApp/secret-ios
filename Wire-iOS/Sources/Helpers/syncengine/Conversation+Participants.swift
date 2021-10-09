

import Foundation

extension ZMConversation {
    private enum NetworkError: Error {
        case offline
    }
    
    @objc static let maxVideoCallParticipants: Int = 4
    
    @objc static let maxParticipants: Int = 128
    
    @objc static let maxParticipantsInOneChoose: Int = 50
    
    @objc static var maxParticipantsExcludingSelf: Int {
        return maxParticipants - 1
    }
    
    @objc static var maxVideoCallParticipantsExcludingSelf: Int {
        return maxVideoCallParticipants - 1
    }
    
    var freeParticipantSlots: Int {
        if conversationType == .hugeGroup {
            return ZMConversation.maxParticipantsInOneChoose
        }
        let leftParticipantCanAdd = (type(of: self).maxParticipants - activeParticipants.count)
        return (leftParticipantCanAdd < ZMConversation.maxParticipantsInOneChoose ? leftParticipantCanAdd : ZMConversation.maxParticipantsInOneChoose)
    }
    
    @objc(addParticipantsOrShowError:)
    func addOrShowError(participants: Set<ZMUser>) {
        guard let session = ZMUserSession.shared(),
                session.networkState != .offline else {
            self.showAlertForAdding(for: NetworkError.offline)
            return
        }
        
        self.addParticipants(participants,
                             userSession: ZMUserSession.shared()!) { result in
                                switch result {
                                case .failure(let error):
                                    self.showAlertForAdding(for: error)
                                default: break
                                }
        }
    }
    
    @objc (removeParticipantOrShowError:)
    func removeOrShowError(participnant user: ZMUser) {
        removeOrShowError(participnant: user, completion: nil)
    }
    
    func removeOrShowError(participnant user: ZMUser, completion: ((VoidResult)->())? = nil) {
        guard let session = ZMUserSession.shared(),
            session.networkState != .offline else {
            self.showAlertForRemoval(for: NetworkError.offline)
            return
        }

        /// if the user is not in this conversation, result = .success
        self.removeParticipant(user,
                               userSession: ZMUserSession.shared()!) { result in
                                switch result {
                                case .success:
                                    if user.isServiceUser {
                                        Analytics.shared().tagDidRemoveService(user)
                                    }
                                case .failure(let error):
                                    self.showAlertForRemoval(for: error)
                                }
                                
                                completion?(result)
        }
    }
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(
            title: "error.conversation.title".localized,
            message: message,
            alertAction: .ok(style: .cancel)
        )
        UIApplication.shared.topmostViewController(onlyFullScreen: false)?.present(alertController, animated: true)
    }
    
    private func showAlertForAdding(for error: Error) {
        switch error {
        case ConversationAddParticipantsError.tooManyMembers:
            showErrorAlert(message: "error.conversation.too_many_members".localized)
        case NetworkError.offline:
            showErrorAlert(message: "error.conversation.offline".localized)
        default:
            showErrorAlert(message: "error.conversation.cannot_add".localized)
        }
    }
    
    private func showAlertForRemoval(for error: Error) {
        switch error {
        case NetworkError.offline:
            showErrorAlert(message: "error.conversation.offline".localized)
        default:
            showErrorAlert(message: "error.conversation.cannot_remove".localized)
        }
    }
}
