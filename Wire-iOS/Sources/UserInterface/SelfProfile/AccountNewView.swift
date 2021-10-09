

import UIKit
import Cartography

class AccountNewView: UIView, ZMUserObserver {
    
    var userObserverToken: NSObjectProtocol?
    var user: ZMUser{
        didSet{
            userImageView.size = .big
            userImageView.user = user
            nameLabel.text = user.name
            handerLabel.text = "@\(user.handle ?? "")"
        }
    }
    
    var clickListener: (() -> Void)?
    
    public func setClickListener(listener: (() -> Void)?) {
        clickListener = listener
    }
    
    init(user: ZMUser) {
        self.user = user
        super.init(frame: .zero)
        backgroundColor = .dynamic(scheme: .barBackground)
        userObserverToken = UserChangeInfo.add(observer: self, for: user, userSession: ZMUserSession.shared()!)
        [userImageView, nameLabel, handerLabel, qrImgView, arrowImageView].forEach(addSubview)
        arrowImageView.setIcon(.disclosureIndicator, size: .like, color: .dynamic(scheme: .accessory))
        createConstraints()
        addGesture()
    }
    
    func createConstraints() {
        constrain(self,userImageView,nameLabel,handerLabel,arrowImageView) { (view,userimageview,namelabel,handerlabel,arrowimageview) in
            userimageview.left == view.left + 26
            userimageview.centerY == view.centerY
            userimageview.width == 70
            userimageview.height == 70
            namelabel.left == userimageview.right + 22
            namelabel.centerY == userimageview.centerY - 12
            handerlabel.left == namelabel.left
            handerlabel.centerY == userimageview.centerY + 12
            arrowimageview.centerY == view.centerY
            arrowimageview.right == view.right - 20
        }
        
        constrain(qrImgView, arrowImageView, self) { (qr, arrow, s) in
            qr.centerY == s.centerY
            qr.right == arrow.left - 10
            qr.width == 22
            qr.height == qr.width
        }
    }
    
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(AccountNewView.tap))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func tap() {
        self.clickListener?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var userImageView: UserImageView = {
        let imageView = UserImageView()
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        imageView.user = self.user
        imageView.userSession = ZMUserSession.shared()
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(16, .regular)
        label.textColor = .dynamic(scheme: .title)
        label.text = self.user.name
        return label
    }()
    
    private lazy var handerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(13, .regular)
        label.textColor = .dynamic(scheme: .subtitle)
        label.text = "@\(self.user.handle ?? "")"
        return label
    }()
    
    private lazy var qrImgView = UIImageView(image: #imageLiteral(resourceName: "QRcode"))
    
    private let arrowImageView = ThemedImageView()
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        self.user = ZMUser.selfUser()
    }
}
