
import Foundation
import WireDataModel

extension UserType {

    var pov: PointOfView {
        return self.isSelfUser ? .secondPerson : .thirdPerson
    }

    var isPendingApproval: Bool {
        return isPendingApprovalBySelfUser || isPendingApprovalByOtherUser
    }

    var hasUntrustedClients: Bool {
        return allClients.contains { !$0.verified }
    }
}
