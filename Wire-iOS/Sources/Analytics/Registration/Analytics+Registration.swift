

import Foundation

extension Analytics {
    func tagRegistrationSucceded(context: String) {
        self.tagEvent("registration.succeeded", attributes: ["context": context])
    }
    
    func tagOpenedLandingScreen(context: String) {
        self.tagEvent("start.opened_start_screen", attributes: ["context": context])
    }
    
    func tagOpenedUserRegistration(context: String) {
        self.tagEvent("start.opened_person_registration", attributes: ["context": context])
    }
    
    func tagOpenedTeamCreation(context: String) {
        self.tagEvent("start.opened_team_registration", attributes: ["context": context])
    }
    
    func tagOpenedLogin(context: String) {
        self.tagEvent("start.opened_login", attributes: ["context": context])
    }
        
    enum InviteResult {
        case none
        case invited(invitesCount: Int)
    }
    
    func tagTeamFinishedInviteStep(with result: InviteResult) {
        let attributes: [String : Any]
        
        switch(result) {
        case .none:
            attributes = ["invited": false,
                          "invites:": 0]
        case .invited(let invitesCount):
            attributes = ["invited": true,
                          "invites:": invitesCount]
        }
        
        tagEvent("team.finished_invite_step", attributes: attributes)
    }
}
