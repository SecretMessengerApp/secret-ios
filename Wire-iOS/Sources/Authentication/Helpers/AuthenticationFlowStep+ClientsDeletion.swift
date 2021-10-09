
import Foundation

extension AuthenticationFlowStep {

    static func makeClientManagementStep(from error: NSError, credentials: ZMCredentials?, statusProvider: AuthenticationStatusProvider?) -> AuthenticationFlowStep? {
        guard let userClientIDs = error.userInfo[ZMClientsKey] as? [NSManagedObjectID] else {
            return nil
        }

        let clients: [UserClient] = userClientIDs.compactMap {
            guard let session = statusProvider?.sharedUserSession else {
                return nil
            }

            guard let object = try? session.managedObjectContext.existingObject(with: $0) else {
                return nil
            }

            return object as? UserClient
        }

        return .clientManagement(clients: clients, credentials: credentials)
    }

}
