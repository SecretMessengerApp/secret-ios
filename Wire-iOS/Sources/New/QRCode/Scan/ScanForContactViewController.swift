//
//  ScanForContactViewController.swift
//  Wire-iOS
//
import UIKit
import Cartography

class ScanForContactViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.dynamic(scheme: .background)
        let scanVC = QRCodeScanViewController { [weak self] result in
            self?.handle(result: result)
        }
        addChild(scanVC)
        view.addSubview(scanVC.view)
        constrain(scanVC.view, view) { (scan, v) in
            scan.edges == v.edges
        }
    }

    private func backBtnClicked() {
        navigationController?.popViewController(animated: true)
    }

    private func handle(result: String?) {
        guard let result = result else {
            HUD.error("hud.error.invalid.qrcode".localized)
            backBtnClicked()
            return
        }
        let resolver = QRCodeResolver(string: result)
        switch resolver.model.type {
        case .friend(let id): showUserProfile(id: id)

        case .newFriend(let id): showUserProfileWithPrivateID(id: id)
            
        case .group(let url):
            let manager = JoinConversationManager(inviteURLString: url)
            if manager.isValidInviteURL {
                manager.checkOrPresentJoinAlert(on: self, completion: backBtnClicked)
            } else {
                HUD.error("hud.error.invalid.qrcode".localized, completion: backBtnClicked)
            }

        case .login(let id):
            loginWeb(qr: id, completion: backBtnClicked)
            
        case .h5Auth(let code):
            h5Auth(code: code, completion: backBtnClicked)

        case .unknown: HUD.error("hud.error.invalid.qrcode".localized, completion: backBtnClicked)
        }
    }
}


// MARK: - Search User
extension ScanForContactViewController {
    
    private func showUserProfileWithPrivateID(id: String) {
        HUD.loading()
        PrivateIdentifierService.getUserInfoWithPrivateIdentifier(id, completion: {[weak self] (result) in
            HUD.hide()
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if let id = data["data"]["id"].string {
                    self.showUserProfile(id: id)
                } else {
                    HUD.error("hud.error.not.find.user".localized, completion: self.backBtnClicked)
                    return
                }
                
            case .failure:
                HUD.error("hud.error.not.find.user".localized, completion: self.backBtnClicked)
                return
            }
        })
        
    }
    
    private func showUserProfile(id: String) {
        ZMUser.createUserIfNeededWithRemoteID(id) {[weak self] (user) in
            guard let self = self else { return }
            guard let user = user else {
                HUD.error("hud.error.not.find.user".localized, completion: self.backBtnClicked)
                return
            }
            if user.isSelfUser {
                HUD.error("hud.error.self.qrcode".localized, completion: self.backBtnClicked)
                return
            }
            let userProfileViewController = UserProfileViewController(user: user,
                                                                      connectionConversation: user.connection?.conversation,
                                                                      userProfileViewControllerDelegate: self)
            
            self.navigationController?.pushViewController(userProfileViewController, animated: true)
        }
    }
    

}

extension ScanForContactViewController: UserProfileViewControllerDelegate {
    
    func wantsToNavigateToConversation(_ conversation: ZMConversation) {
        dismiss(animated: true) {
            ZClientViewController.shared?.load(
                conversation,
                scrollTo: nil,
                focusOnView: true,
                animated: true
            )
        }
    }
}

// MARK: - ProfileViewControllerDelegate
extension ScanForContactViewController: ProfileViewControllerDelegate {
    func profileViewController(_ controller: ProfileViewController?,
                               wantsToNavigateTo conversation: ZMConversation) {
        ZClientViewController.shared?.load(conversation, scrollTo: nil,
                                             focusOnView: true, animated: true)
    }
    
    func profileViewController(_ controller: ProfileViewController?, wantsToCreateConversationWithName name: String?, users: UserSet) {
        //no-op
    }
}

// MARK: - Login Web
extension ScanForContactViewController {
    private func loginWeb(qr: String, completion: @escaping () -> Void) {
        HUD.loading()
        ScanForLoginService.login(qrString: qr) { result in
            HUD.hide()
            completion()
            switch result {
            case .success:
                HUD.text("hud.success.setting.scan.login".localized)
            case .failure:
                HUD.text("hud.failed.setting.scan.login".localized)
            }
        }
    }
}


extension ScanForContactViewController {
    
    private func h5Auth(code: String, completion: @escaping () -> Void) {
        let controller = H5AuthViewController(code: code)
        present(controller, animated: true)
    }
}
