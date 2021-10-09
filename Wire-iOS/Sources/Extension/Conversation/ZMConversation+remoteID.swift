//
//  ZMConversation+remoteID.swift
//  Wire-iOS
//

extension ZMConversation {
    convenience init?(
        remoteID: UUID,
        createIfNeeded: Bool = false,
        in context: NSManagedObjectContext? = ZMUserSession.shared()?.managedObjectContext
        ) {
        guard let context = context else { return nil }
        self.init(remoteID: remoteID, createIfNeeded: createIfNeeded, in: context)
    }
    

    static func createConversationIfNeededWithRemoteID(_ remoteID: String, needsToBeUpdatedFromBackend: Bool, complete: @escaping (ZMConversation?) -> Void) {
        guard let uuid = UUID(uuidString: remoteID) else {
            complete(nil)
            return
        }
        if let conv = ZMConversation(remoteID: uuid) {
            complete(conv)
            return
        }
        ZMUserSession.shared()?.syncManagedObjectContext.perform {
            if let newConv = ZMConversation.init(remoteID: uuid,
                                         createIfNeeded: true,
                                         in: ZMUserSession.shared()?.syncManagedObjectContext){
                newConv.needsToBeUpdatedFromBackend = needsToBeUpdatedFromBackend
                try! ZMUserSession.shared()?.syncManagedObjectContext.save()
            }
            
            DispatchQueue.main.async {
                complete(ZMConversation(remoteID: uuid))
            }
        }
    }
}


