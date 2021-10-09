
import Foundation

extension AuthenticationCoordinator: LandingViewControllerDelegate {

    func landingViewControllerDidChooseLogin() {
        if let fastloginCredentials = AutomationHelper.sharedHelper.automationEmailCredentials {
            let loginRequest = AuthenticationLoginRequest.email(address: fastloginCredentials.email, password: fastloginCredentials.password)
            executeActions([.showLoadingView, .startLoginFlow(loginRequest)])
        } else {
            stateController.transition(to: .provideCredentials(.email, nil))
        }
    }

    func landingViewControllerDidChooseCreateAccount() {
        let unregisteredUser = makeUnregisteredUser()
//        let usePhone = UIDevice.current.userInterfaceIdiom == .phone
        let usePhone = false
        stateController.transition(to: .createCredentials(unregisteredUser, usePhone ? .phone : .email))
    }

    func landingViewControllerDidChooseCreateTeam() {
        stateController.transition(to: .teamCreation(.setTeamName))
    }

}
