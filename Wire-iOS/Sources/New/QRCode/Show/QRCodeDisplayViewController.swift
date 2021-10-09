

import UIKit

class QRCodeDisplayViewController: UIViewController {
    
    enum Context {
        case group(conversation: ZMConversation), mine
    }
    
    private var context: Context
    
    init(context: Context) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        view.backgroundColor = UIColor(hex: "#2F90F9")//.dynamic(scheme: .background)
        extendedLayoutIncludesOpaqueBars = true
        
        [backBtn, navTitleLabel, containerView].forEach(view.addSubview)
        [avatarView, titleLabel, codeImgView, centerImgView, tipLabel].forEach(containerView.addSubview)
        view.addSubview(saveButton)
        
        saveButton.addTarget(self, action: #selector(saveBtnClicked), for: .touchUpInside)
        
        makeConstraints()
        
        setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private let navTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(16, .bold)
        label.textAlignment = .center
        label.textColor = .white
        label.text = "conversation.setting.to.group.qrcode".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let backBtn: UIButton = {
        let btn = UIButton()
        let img = StyleKitIcon.backArrow.makeImage(size: .tiny, color: .white)
        btn.setImage(img, for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
        return btn
    }()
    
    @objc private func backBtnClicked() {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            if self.presentingViewController != nil {
                self.dismiss(animated: true, completion: nil)
            } else {
                let revealed = wr_splitViewController?.isLeftViewControllerRevealed ?? false
                wr_splitViewController?.setLeftViewControllerRevealed(!revealed, animated: true, completion: nil)
            }
        }
    }
    
    private func setupData() {
        switch context {
        case .group(let conversation):
            navTitleLabel.text = "conversation.setting.to.group.qrcode".localized
            avatarView.configure(context: .conversation(conversation: conversation))
            centerImgView.configure(context: .conversation(conversation: conversation))
            titleLabel.text = conversation.meaningfulDisplayName
            tipLabel.text = "conversation.group.tips".localized
            saveButton.setTitle("conversation.group.qrcode.save".localized, for: .normal)
            guard let url = conversation.joinGroupUrl else { return }
            DispatchQueue.global().async {
                let img = QRCodeGenerator.generate(type: .group(url: url))
                DispatchQueue.main.async {
                    self.codeImgView.image = img
                }
            }
        case .mine:
            navTitleLabel.text = "self.settings.account_section.myQRCode.title".localized
            avatarView.configure(context: .connect(users: [ZMUser.selfUser()]))
            centerImgView.configure(context: .connect(users: [ZMUser.selfUser()]))
            titleLabel.text = ZMUser.selfUser().name
            generateMineQRCode()
            tipLabel.text = "settings.qrcode.tips".localized
            saveButton.setTitle("settings.qrcode.save".localized, for: .normal)
        }
    }
    
    private func generateMineQRCode() {
        guard let user = ZMUser.selfUser() else { return }
            
        func generateImageWithPrivateIdentifier(_ id: String) {
            let type = QRCodeModel.ModelType.newFriend(id: id)
            DispatchQueue.global().async {
                let img = QRCodeGenerator.generate(type: type)
                DispatchQueue.main.async {
                    self.codeImgView.image = img
                }
            }
        }
        func getSelfPrivateIdentifier() {
            HUD.loading()
            PrivateIdentifierService.getSelfPrivateIdentifier { [weak self] result in
                HUD.hide()
                switch result {
                case .success(let data):
                    if let privateIdentifier = data["data"]["extid"].string {
                        ZMUserSession.shared()?.enqueueChanges {
                            user.privateIdentifier = privateIdentifier
                        }
                        generateImageWithPrivateIdentifier(privateIdentifier)
                    } else {
                        HUD.error("hud.error.unkown".localized)
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .failure: HUD.error("hud.error.unkown".localized)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        if let privateIdentifier = user.privateIdentifier {
            generateImageWithPrivateIdentifier(privateIdentifier)
        } else {
            getSelfPrivateIdentifier()
        }
    }
    
    @objc private func saveBtnClicked() {
        guard let img = image(from: containerView) else { return }
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    private func image(from view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.layer.frame.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            HUD.error("hud.error.unkown".localized)
        } else {
            HUD.success("hud.success.saved".localized)
        }
    }
    
    private func makeConstraints() {
        [backBtn, navTitleLabel, containerView, avatarView, titleLabel, codeImgView, centerImgView, tipLabel, saveButton].prepareForLayout()
        
        var constraints: [NSLayoutConstraint] = []
        
        constraints += [
//            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        constraints += [
            backBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backBtn.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.safeArea.top + 16),
            
            navTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            navTitleLabel.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor)
        ]
        
        constraints += [
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            avatarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),
            
            titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8),
            
            codeImgView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            codeImgView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
//            codeImgView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            codeImgView.widthAnchor.constraint(equalToConstant: min(UIScreen.main.bounds.width, 375) - 48 - 32),
            codeImgView.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 16),
            codeImgView.heightAnchor.constraint(equalTo: codeImgView.widthAnchor),
            
            centerImgView.centerXAnchor.constraint(equalTo: codeImgView.centerXAnchor),
            centerImgView.centerYAnchor.constraint(equalTo: codeImgView.centerYAnchor),
            centerImgView.widthAnchor.constraint(equalToConstant: 48),
            centerImgView.heightAnchor.constraint(equalToConstant: 48),
            
            tipLabel.topAnchor.constraint(equalTo: codeImgView.bottomAnchor, constant: 16),
            tipLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            tipLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            tipLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -16)
        ]
        constraints += [
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            saveButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeBottomAnchor, constant: -16)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .secondaryBackground)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var avatarView: ConversationAvatarView = ConversationAvatarView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(15, .regular)
        label.textColor = .dynamic(scheme: .title)
        return label
    }()
    
    private lazy var codeImgView = UIImageView()
    
    private lazy var centerImgView: ConversationAvatarView = {
        let view = ConversationAvatarView()
        view.cornerRadius = 24
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.white.cgColor
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(13, .regular)
        label.textColor = .dynamic(scheme: .note)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "settings.qrcode.tips".localized
        return label
    }()
    
    private lazy var saveButton: UIButton = {
       let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "user_qr_save"), for: .normal)
        button.setTitle("settings.qrcode.save".localized, for: .normal)
        button.setTitleColor(UIColor.init(hex: "#FFFFFF"), for: .normal)
        button.titleLabel?.font = UIFont(15, .regular)
        button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -10, bottom: 0.0, right: 0.0)
        return button
    }()
}
