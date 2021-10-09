
import Foundation

class SettingsSignOutCellDescriptor: SettingsExternalScreenCellDescriptor {
    
    var requestPasswordController: RequestPasswordController?
    
    init() {
        super.init(title: "self.sign_out".localized,
                   isDestructive: true,
                   presentationStyle: .modal,
                   identifier: nil,
                   presentationAction: { return nil },
                   previewGenerator: nil,
                   icon: nil,
                   accessoryViewMode: .default)
        

    }
    
    func logout(password: String? = nil) {
        guard let selfUser = ZMUser.selfUser() else { return }
    
        if selfUser.usesCompanyLogin || password != nil {
            ZClientViewController.shared?.showLoadingView = true
            ZMUserSession.shared()?.logout(credentials: ZMEmailCredentials(email: "", password: password ?? ""), { (result) in
                ZClientViewController.shared?.showLoadingView = false
                
                if case .failure(let error) = result {
                    ZClientViewController.shared?.showAlert(for: error)
                }
            })
        } else {
            guard let account = SessionManager.shared?.accountManager.selectedAccount else { return }
            
            SessionManager.shared?.delete(account: account)
        }
        
    }
    
    override func generateViewController() -> UIViewController? {
        guard let selfUser = ZMUser.selfUser() else { return nil }
        
        var viewController: UIViewController? = nil
        
        if selfUser.emailAddress == nil || selfUser.usesCompanyLogin {
            let alert = UIAlertController(title: "self.settings.account_details.log_out.alert.title".localized,
                                          message: "self.settings.account_details.log_out.alert.message".localized,
                                          preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "general.cancel".localized, style: .cancel, handler: nil)
            let actionLogout = UIAlertAction(title: "general.ok".localized, style: .destructive, handler: { [weak self] _ in
                self?.logout()
            })
            alert.addAction(actionCancel)
            alert.addAction(actionLogout)
            
            viewController = alert
        } else {
            requestPasswordController = RequestPasswordController(context: .logout, callback: { [weak self] (password) in
                guard let password = password else { return }
                
                self?.logout(password: password)
            })
            
            viewController = requestPasswordController?.alertController
        }
        
        return viewController
    }
    
}
