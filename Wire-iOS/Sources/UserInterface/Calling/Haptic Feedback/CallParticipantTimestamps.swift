
import Foundation

final class CallParticipantTimestamps {

    private var participants = Set<CallParticipant>()
    private var participantTimestamps = [CallParticipant: Date]()
    
    func updateParticipants(_ newParticipants: [CallParticipant]) {
        let updated = Set(newParticipants)
        let removed = participants.subtracting(updated)
        let added = updated.subtracting(participants)
        
        removed.forEach {
            Log.callTimestamps.debug("Removing timestamp for \($0)")
            participantTimestamps[$0] = nil
        }
        added.forEach {
            Log.callTimestamps.debug("Adding timestamp for \($0)")
            participantTimestamps[$0] = .init()
        }
        
        participants = updated
    }
    
    subscript(_ participant: CallParticipant) -> Date? {
        return participantTimestamps[participant]
    }

}
