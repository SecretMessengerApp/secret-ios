

import UIKit

class H5AuthViewController: BaseAuthViewController {

    private var code: String
    private var url: String?
    
    init(code: String, url: String? = nil) {
        self.code = code
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchInfo() {
        config(iconImage: UIImage.init(named: "logo_cartoon"), name: "SecretWorth Website authorization")
    }
    
    override func authBtnDidTap() {
        H5AuthService.auth(code: code) { result in
            switch result {
            case .success:
                if let callBackUrl = self.url, let callURL = URL(string: callBackUrl) {
                    UIApplication.shared.open(callURL, options: [:], completionHandler: nil)
                }
                self.dismiss(animated: true) { HUD.success("app.scheme.h5.auth.success".localized)
                }
            case .failure(let msg): HUD.error(msg)
            }
        }
    }
}


class H5AuthService: NetworkRequest {
    
    class func info(code: String) {
        
    }
    
    class func auth(code: String, completion: @escaping (BaseResult<(), String>) -> Void) {
        
        request(API.Base.backend + API.H5Auth.accept,
                method: .post,
                parameters: ["code2d": code],
                encoding: .json(.default)
            ).responseDataErrorBeLocalized { (response) in
                switch response.result {
                case .success: completion(.success)
                case .failure(let err): completion(.failure(err.localizedDescription))
                }
        }
    }
}
