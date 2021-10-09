
import Foundation

extension AuthenticationCoordinator: CompanyLoginControllerDelegate {

    func controller(_ controller: CompanyLoginController, presentAlert alert: UIAlertController) {
        if presenter?.view.window == nil {
            // the alert cannot be presented now, queue it for later
            pendingModal = alert
        } else {
            presenter?.present(alert, animated: true)
        }
    }

    func controller(_ controller: CompanyLoginController, showLoadingView: Bool) {
        presenter?.showLoadingView = showLoadingView
    }

    func controllerDidStartCompanyLoginFlow(_ controller: CompanyLoginController) {
        stateController.transition(to: .companyLogin)
    }

    func controllerDidCancelCompanyLoginFlow(_ controller: CompanyLoginController) {
        cancelCompanyLogin()
    }

}
