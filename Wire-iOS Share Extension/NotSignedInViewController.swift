
import Foundation
import Cartography

class NotSignedInViewController : UIViewController {
    
    var closeHandler : (() -> Void)?
    
    let messageLabel = UILabel()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "share_extension.not_signed_in.close_button".localized,
            style: .done,
            target: self,
            action: #selector(onCloseTapped)
        )
        
        messageLabel.text = "share_extension.not_signed_in.title".localized
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        view.addSubview(messageLabel)
        
        constrain(view, messageLabel) { container, messageLabel in
            messageLabel.edges == container.edgesWithinMargins
        }
    }
    
    @objc func onCloseTapped() {
        closeHandler?()
    }
}
