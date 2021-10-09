//
//  ScanForConversationListViewController.swift
//  Wire-iOS
//

import UIKit
import Cartography
import YPImagePicker

class ScanForConversationListViewController: UIViewController {

    enum ScanType: Int {
        case QRCode = 0
    }
    
    private var scanVC: QRCodeScanViewController?
    private var scanType: ScanType = .QRCode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.extendedLayoutIncludesOpaqueBars = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(icon: .backArrow, style: .plain, target: self, action: #selector(backBtnClicked))
        navigationItem.rightBarButtonItem = UIBarButtonItem(icon: .photo, target: self, action: #selector(photoBtnClicked))
        navigationController?.navigationBar.barTintColor = UIColor.dynamic(scheme: .barBackground)
        
        
        self.scanVC = QRCodeScanViewController { [weak self] result in
            self?.handle(result: result)
        }
        addChild(scanVC!)
        view.addSubview(scanVC!.view)
        view.addSubview(scanToolsBarContainer)
        scanToolsBarContainer.addSubview(scanToolsBar)
        view.addSubview(arViewContainer)
        view.addSubview(showImageView)
        view.addSubview(aninView)
        self.createConstraints()
        self.setListeners()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanVC?.restart()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopQR()
    }
    
    private func startQR() {
        scanVC?.start()
        self.hiddenAllView()
        self.showQRView()
    }
    
    private func stopQR() {
        scanVC?.stop()
        self.hiddenQRView()
    }
    
    private func showQRView() {
        self.scanVC!.view.isHidden = false
    }
    private func hiddenQRView() {
        self.scanVC!.view.isHidden = true
    }
    
    private func showShowImage() {
        self.showImageView.isHidden = false
    }
    private func hiddenShowImage() {
        self.showImageView.isHidden = true
    }
    
    private func hiddenAllView() {
        self.hiddenShowImage()
        self.hiddenQRView()
    }
    
    private func delayToolsClickable() {
        delay(2) {
            self.scanToolsBar.clickable = true
        }
    }
    
    private func dimissImagePicker(completion: (() -> Void)? = nil) {
        imagePickerHelper.dismissPicker(completion: completion)
    }

    private lazy var imagePickerHelper: YPImagePickerHelper = {
        let pickerHelper = YPImagePickerHelper(type: .QRCodeInAblum, completionPick: { [weak self] items, isCancelled in
            if isCancelled { self?.dimissImagePicker()  }
            self?.dimissImagePicker {
                if  let item = items.first,
                    case let .photo(mediaItem) = item {
                    if case .QRCode? = self?.scanType {
                        let result = QRCodeImageDecoder(image: mediaItem.image).decode()
                        self?.handle(result: result)
                    }
                } else {
                    HUD.error("hud.error.no.qrcode".localized)
                }
            }
        })
        return pickerHelper
    }()
    
    func createConstraints() {
        constrain(scanVC!.view,
                  view,
                  scanToolsBarContainer,
                  scanToolsBar,
                  arViewContainer) { (scan, v, container, scanToolsBar, ar) in
                    scan.top == v.top
                    scan.left == v.left
                    scan.right == v.right
                    scan.bottom == container.top
                    
                    container.left == v.left
                    container.right == v.right
                    container.bottom == v.bottom
                    container.height == 60 + UIScreen.safeArea.bottom
                    
                    scanToolsBar.left == container.left
                    scanToolsBar.right == container.right
                    scanToolsBar.top == container.top
                    scanToolsBar.height == 60
                    
                    ar.top == v.top
                    ar.left == v.left
                    ar.right == v.right
                    ar.bottom == container.top
        }
        
        constrain(showImageView, arViewContainer) { (show, cont) in
            show.edges == cont.edges
        }
        constrain(aninView, arViewContainer) { (ani, ar) in
            ani.edges == ar.edges
        }
    }
    
    func setListeners() {
        self.scanToolsBar.selectListener = { [unowned self] index in
            self.scanType = ScanType(rawValue: index) ?? .QRCode
            switch self.scanType {
            case .QRCode:
                self.startQR()
            }
        }
        
    }
    
    @objc private func photoBtnClicked() {
        imagePickerHelper.presentPicker(by: self)
    }

    @objc private func backBtnClicked() {
        if self.presentingViewController != nil {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.dismiss()
        }
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
            
        case .unknown:
            if let url = URL(string: result),
                ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
                let rootViewcontroller = (UIApplication.shared.delegate as? AppDelegate)?.rootViewController {
                 url.openInApp(above: rootViewcontroller)
               return
            }
            HUD.error("hud.error.invalid.qrcode".localized, completion: backBtnClicked)
        }
    }
    
    private func dismiss() {
        self.stopQR()
        let revealed = self.wr_splitViewController?.isLeftViewControllerRevealed ?? false
        self.wr_splitViewController?.setLeftViewControllerRevealed(!revealed, animated: false, completion: nil)
    }
    
    private lazy var scanToolsBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#333333")
        view.alpha = 0.9
        return view
    }()
    
    private lazy var scanToolsBar: ScanToolsbar = {
        let bar = ScanToolsbar(frame: CGRect.zero)
        return bar
    }()
    
    private lazy var arViewContainer: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private lazy var aninView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private var showImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.isHidden = true
        imageview.isUserInteractionEnabled = true
        imageview.contentMode = .scaleAspectFill
        return imageview
    }()
}

// MARK: - Search User
extension ScanForConversationListViewController {
    
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

extension ScanForConversationListViewController: UserProfileViewControllerDelegate {
    
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
extension ScanForConversationListViewController: ProfileViewControllerDelegate {
    func profileViewController(_ controller: ProfileViewController?,
                               wantsToNavigateTo conversation: ZMConversation) {
        ZClientViewController.shared?.load(conversation, scrollTo: nil,
                                             focusOnView: true, animated: true)
    }
    
    func profileViewController(_ controller: ProfileViewController?, wantsToCreateConversationWithName name: String?, users: UserSet) {
        //no-op
    }
}

extension ScanForConversationListViewController: ViewControllerDismisser {
    func dismiss(viewController: UIViewController, completion: (() -> Void)?) {
        self.dismiss()
    }
}

// MARK: - Login Web
extension ScanForConversationListViewController {
    private func loginWeb(qr: String, completion: @escaping () -> Void) {
        HUD.loading()
        ScanForLoginService.login(qrString: qr) { result in
            HUD.hide()
            switch result {
            case .success:
                HUD.text("hud.success.setting.scan.login".localized, completion: completion)
            case .failure:
                HUD.text("hud.failed.setting.scan.login".localized, completion: completion)
            }
        }
    }
}


extension ScanForConversationListViewController {
    
    private func h5Auth(code: String, completion: @escaping () -> Void) {
        let controller = H5AuthViewController(code: code)
        present(controller, animated: true)
    }
}
