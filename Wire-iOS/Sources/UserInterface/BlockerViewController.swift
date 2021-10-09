
import Foundation

enum BlockerViewControllerContext {
    case blacklist
    case jailbroken
}

class BlockerViewController : LaunchImageViewController {
    
    private var context: BlockerViewControllerContext = .blacklist
    
    init(context: BlockerViewControllerContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showAlert()
    }
    
    func showAlert() {
        switch context {
        case .blacklist:
            showBlacklistMessage()
        case .jailbroken:
            showJailbrokenMessage()
        }
    }
    
    func showBlacklistMessage() {
        presentAlertWithOKButton(title: "force.update.title".localized, message: "force.update.message".localized) { _ in
            UIApplication.shared.open(URL.wr_wireAppOnItunes)
        }
    }
    
    func showJailbrokenMessage() {
        presentAlertWithOKButton(title: "jailbrokendevice.alert.title".localized, message: "jailbrokendevice.alert.message".localized)
    }
    
}
