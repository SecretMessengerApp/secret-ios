//
//  ThridLoginConfirmViewController.swift
//  Wire-iOS
//

import UIKit

class AuthLoginViewController: UIViewController {
    
    private var appid: String
    private var key: String
    
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var authTitle: UILabel!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var getInfoLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    init(appid: String, key: String) {
        self.appid = appid
        self.key = key
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamic(scheme: .background)
        authTitle.textColor = .dynamic(scheme: .title)
        appName.textColor = .dynamic(scheme: .title)
        getInfoLabel.textColor = .dynamic(scheme: .note)
        cancelButton.layer.cornerRadius = 9
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.layer.borderWidth = .hairline
        self.setDatas()
    }
    
    func setDatas() {
        self.authTitle.text = "Secret " + "app.scheme.login.authorization".localized
        self.getInfoLabel.text = "app.scheme.login.get.information".localized
        self.confirmButton.setTitle("app.scheme.login.auth.allow".localized, for: .normal)
        self.cancelButton.setTitle("app.scheme.login.auth.refuse".localized, for: .normal)
    }
    
    @IBAction func cancleClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmClick() {
        let scheme = "secret" + self.appid
        AuthLoginService.appLoginAuth(appid: self.appid, key: self.key, completion: { (result) in
            switch result {
            case .success:
                HUD.success("Authorized")
                if let url = URL.init(string: scheme+"://"+"callback?app_id="+self.appid+"&key="+self.key) {
                    UIApplication.shared.open(url, completionHandler: nil)
                }
                self.dismiss(animated: true, completion: nil)
            case .failure(let msg):
                HUD.error(msg)
            }
        })
    }
}
