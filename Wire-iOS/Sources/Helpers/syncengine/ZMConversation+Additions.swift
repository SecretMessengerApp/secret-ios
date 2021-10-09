

import Foundation

extension ZMConversation {

    ///TODO: move to DM
    var firstActiveParticipantOtherThanSelf: ZMUser? {
        // TODO: ToSwift localParticipants
        guard let selfUser = ZMUser.selfUser() else { return activeParticipants.first }
        return activeParticipants.first(where: { $0 != selfUser })
        
//        guard let selfUser = ZMUser.selfUser() else { return localParticipants.first }
//        return localParticipants.first(where: {$0 != selfUser} )
    }
}
