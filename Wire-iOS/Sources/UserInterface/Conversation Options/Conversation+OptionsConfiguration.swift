

extension ZMConversation {
    
    class OptionsConfigurationContainer: NSObject, ConversationOptionsViewModelConfiguration, ZMConversationObserver {
        
        private var conversation: ZMConversation
        private var token: NSObjectProtocol?
        private let userSession: ZMUserSession
        var allowGuestsChangedHandler: ((Bool) -> Void)?
        
        init(conversation: ZMConversation, userSession: ZMUserSession) {
            self.conversation = conversation
            self.userSession = userSession
            super.init()
            token = ConversationChangeInfo.add(observer: self, for: conversation)
        }
        
        var title: String {
            return conversation.displayName.localizedUppercase
        }
        
        var allowGuests: Bool {
            return conversation.allowGuests
        }
        
        var isCodeEnabled: Bool {
            return conversation.accessMode?.contains(.code) ?? false
        }

        var areGuestOrServicePresent: Bool {
            return conversation.areGuestsPresent || conversation.areServicesPresent
        }

        func setAllowGuests(_ allowGuests: Bool, completion: @escaping (VoidResult) -> Void) {
            conversation.setAllowGuests(allowGuests, in: userSession) {
                switch $0 {
                case .success: Analytics.shared().tagAllowGuests(value: allowGuests)
                case .failure: break
                }
                completion($0)
            }
        }
        
        func conversationDidChange(_ changeInfo: ConversationChangeInfo) {
            guard changeInfo.allowGuestsChanged else { return }
            allowGuestsChangedHandler?(allowGuests)
        }
        
        func createConversationLink(completion: @escaping (Result<String>) -> Void) {
            conversation.updateAccessAndCreateWirelessLink(in: userSession, completion)
        }

        func fetchConversationLink(completion: @escaping (Result<String?>) -> Void) {
            conversation.fetchWirelessLink(in: userSession, completion)
        }
        
        func deleteLink(completion: @escaping (VoidResult) -> Void) {
            conversation.deleteWirelessLink(in: userSession, completion)
        }

    }
    
}
