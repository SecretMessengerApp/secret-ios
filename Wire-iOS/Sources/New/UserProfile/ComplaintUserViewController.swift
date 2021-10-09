

import UIKit
import Cartography
import Alamofire

class ComplaintUserViewController: UIViewController {
    private let maxTextCount = 250
    
    private lazy var postButton: IconButton = {
        let btn = IconButton()
        btn.setTitle("newProfile.conversation.complaint.submit".localized, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
        btn.titleLabel?.font = UIFont(14, .regular)
        return btn
    }()
    
    private lazy var textView = TextView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .dynamic(scheme: .background)
        title = "newProfile.conversation.complaint.title".localized
        makeViewAndConstraints()
        textView.delegate = self
        textView.tintColor = .dynamic(scheme: .brand)
        textView.textColor = .dynamic(scheme: .title)
        textView.backgroundColor = .dynamic(scheme: .background)
        textView.font = UIFont.normalMediumFont
        textView.becomeFirstResponderIfPossible()
    }
    

    private func makeViewAndConstraints() {
        
        postButton.addTarget(self, action: #selector(postButtonClicked), for: .touchUpInside)
        let item = UIBarButtonItem(customView: postButton)
        navigationItem.rightBarButtonItem = item

        view.addSubview(textView)
        constrain(textView, view) { textView, view in
            textView.edges == view.edges.inseted(by: 15)
        }
    }
    
    @objc private func postButtonClicked() {
        guard let text = self.textView.text, text != "" else {
            HUD.error("newProfile.conversation.complaint.placeHolder".localized)
            return
        }
        
        HUD.loading()
        NetworkManager.manager.request(
            "https://service.isecret.im/Account/report",
            method: .post,
            parameters: ["text": text],
            encoding: URLEncoding.default,
            headers: nil,
            interceptor: nil,
            requestModifier: nil
        ).responseJSON { (response) in
            switch response.result {
                case .failure:
                    HUD.success("newProfile.conversation.complaint.success".localized)
                    self.dismiss()
                case .success:
                    HUD.success("newProfile.conversation.complaint.success".localized)
                    self.dismiss()
            }
        }
    }
    
    private func dismiss() {
        guard let navController = self.navigationController else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        guard navController.viewControllers.count > 1 else {
            navController.dismiss(animated: true, completion: nil)
            return
        }
        navController.popViewController(animated: true)
    }

}

extension ComplaintUserViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView.text.count > maxTextCount else { return }
        let startIndex = textView.text.startIndex
        let endIndex = textView.text.index(startIndex, offsetBy: maxTextCount)
        let subText = String(textView.text[startIndex..<endIndex])
        self.textView.text = subText
        HUD.error("conversation_announcement.hud.announcement_max_count".localized)
    }
}
