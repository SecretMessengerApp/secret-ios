
import Foundation

fileprivate extension ZMConversation {
    var otherNonServiceParticipants: [UserType] {
        guard let users = lastServerSyncedActiveParticipants.array as? [UserType] else { return [] }
        return users.filter { !$0.isServiceUser }
    }
}

struct ServiceAddedEvent: Event {
    struct Keys {
        static let serviceID = "service_id"
        static let conversationSize = "conversation_size"
        static let servicesSize = "services_size"
        static let methods = "methods"
    }

    enum Context: String {
        case startUI = "start_ui"
        case conversationDetails = "conversation_details"
    }
    
    private let conversationSize, servicesSize: Int
    private let serviceIdentifier: String
    private let context: Context
    
    init(service: ServiceUser, conversation: ZMConversation, context: Context) {
        serviceIdentifier = service.serviceIdentifier ?? ""
        conversationSize = conversation.otherNonServiceParticipants.count // Without service users
//        servicesSize = conversation.lastServerSyncedActiveParticipants.count - conversationSize
        servicesSize = 0
        self.context = context
    }
    
    var name: String {
        return "integration.added_service"
    }
    
    var attributes: [AnyHashable : Any]? {
        return [
            Keys.serviceID: serviceIdentifier,
            Keys.conversationSize: conversationSize,
            Keys.servicesSize: servicesSize,
            Keys.methods: context.rawValue
        ]
    }
}

struct ServiceRemovedEvent: Event {
    struct Keys {
        static let serviceID = "service_id"
    }
    
    private let serviceIdentifier: String
    
    init(service: ServiceUser) {
        serviceIdentifier = service.serviceIdentifier ?? ""
    }
    
    var name: String {
        return "integration.removed_service"
    }
    
    var attributes: [AnyHashable : Any]? {
        return [Keys.serviceID: serviceIdentifier]
    }
}

extension Analytics {
    @objc func tagDidRemoveService(_ serviceUser: ServiceUser) {
        tag(ServiceRemovedEvent(service: serviceUser))
    }
}
