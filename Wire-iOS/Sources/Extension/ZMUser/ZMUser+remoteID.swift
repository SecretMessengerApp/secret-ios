//
//  ZMUser+remoteID.swift
//  Wire-iOS
//


extension ZMUser {
    convenience init?(
        remoteID: UUID,
        createIfNeeded: Bool = false,
        in context: NSManagedObjectContext? = ZMUserSession.shared()?.managedObjectContext
        ) {
        guard let context = context else { return nil }
        self.init(remoteID: remoteID, createIfNeeded: createIfNeeded, in: context)
    }
    
    convenience init?(remoteIDString: String) {
        guard let uuid = UUID(uuidString: remoteIDString) else { return nil }
        self.init(remoteID: uuid)
    }
    
    static func createUserIfNeededWithRemoteID(_ remoteID: String, complete: @escaping (ZMUser?) -> Void) {
        guard let uuid = UUID(uuidString: remoteID) else {
            complete(nil)
            return
        }
        if let user = ZMUser(remoteID: uuid) {
            complete(user)
            return
        }
        ZMUserSession.shared()?.syncManagedObjectContext.perform {
            if let newUser = ZMUser.init(remoteID: uuid,
                                         createIfNeeded: true,
                                         in: ZMUserSession.shared()?.syncManagedObjectContext){
                newUser.needsToBeUpdatedFromBackend = true
                try! ZMUserSession.shared()?.syncManagedObjectContext.save()
            }
            
            DispatchQueue.main.async {
                complete(ZMUser(remoteID: uuid))
            }
        }
    }
}
