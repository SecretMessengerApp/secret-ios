
import Foundation

private let zmLog = ZMSLog(tag: "UI")

extension UIViewController {
    
    @discardableResult
    func requestPassword(_ completion: @escaping (ZMEmailCredentials?)->()) -> RequestPasswordController {
        var passwordRequest: RequestPasswordController?
        passwordRequest = RequestPasswordController(context: .removeDevice) { (result: String?) -> () in
            if let email = ZMUser.selfUser()?.emailAddress {
                if let passwordString = result {
                    let newCredentials = ZMEmailCredentials(email: email, password: passwordString)
                    completion(newCredentials)
                }
            } else {
                if Bundle.developerModeEnabled {
                    DebugAlert.showGeneric(message: "No email set!")
                }
                completion(nil)
            }
            passwordRequest = nil
        }
        
        present(passwordRequest!.alertController, animated: true)
        
        return passwordRequest!
    }
}

enum ClientRemovalUIError: Error {
    case noPasswordProvided
}

final class ClientRemovalObserver: NSObject, ZMClientUpdateObserver {
    var userClientToDelete: UserClient
    unowned let controller: UIViewController
    let completion: ((Error?)->())?
    var credentials: ZMEmailCredentials?
    private var requestPasswordController: RequestPasswordController?
    private var passwordIsNecessaryForDelete: Bool = false
    private var observerToken: Any?
    
    init(userClientToDelete: UserClient, controller: UIViewController, credentials: ZMEmailCredentials?, completion: ((Error?)->())? = nil) {
        self.userClientToDelete = userClientToDelete
        self.controller = controller
        self.credentials = credentials
        self.completion = completion
        
        super.init()
        
        observerToken = ZMUserSession.shared()?.add(self)
        
        requestPasswordController = RequestPasswordController(context: .removeDevice, callback: {[weak self] (password) in
            guard let password = password, !password.isEmpty else {
                self?.endRemoval(result: ClientRemovalUIError.noPasswordProvided)
                return
            }
            
            self?.credentials = ZMEmailCredentials(email: "", password: password)
            self?.startRemoval()
            self?.passwordIsNecessaryForDelete = true
        })
    }

    func startRemoval() {
        controller.showLoadingView = true
        ZMUserSession.shared()?.delete(userClientToDelete, with: credentials)
    }
    
    private func endRemoval(result: Error?) {
        completion?(result)
    }
    
    func finishedFetching(_ userClients: [UserClient]) {
        // NO-OP
    }
    
    func failedToFetchClientsWithError(_ error: Error) {
        // NO-OP
    }
    
    func finishedDeleting(_ remainingClients: [UserClient]) {
        controller.showLoadingView = false
        endRemoval(result: nil)
    }
    
    func failedToDeleteClientsWithError(_ error: Error) {
        controller.showLoadingView = false

        if !passwordIsNecessaryForDelete {
            guard let requestPasswordController = requestPasswordController else { return }
            controller.present(requestPasswordController.alertController, animated: true)
        } else {
            controller.presentAlertWithOKButton(message: "self.settings.account_details.remove_device.password.error".localized)
            endRemoval(result: error)

            /// allow password input alert can be show next time
            passwordIsNecessaryForDelete = false
        }
    }
}
