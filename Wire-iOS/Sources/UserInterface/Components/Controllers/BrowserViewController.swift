
import Foundation
import SafariServices

final class BrowserViewController: SFSafariViewController {

    var completion: (() -> Void)?
    var onDismiss: (() -> Void)?

    // MARK: - Tint Color

    private var overrider = TintColorOverrider()
    private var originalStatusBarStyle: UIStatusBarStyle = .default
    private var originalStatusBarVisibility: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredControlTintColor = UIColor.dynamic(scheme: .title)
        view.backgroundColor = UIColor.dynamic(scheme: .background)
        delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        originalStatusBarStyle = UIApplication.shared.statusBarStyle
        originalStatusBarVisibility = UIApplication.shared.isStatusBarHidden
        overrider.override()
        UIApplication.shared.wr_setStatusBarStyle(.default, animated: true)
        UIApplication.shared.wr_setStatusBarHidden(false, with: .fade)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        overrider.restore()
        UIApplication.shared.wr_setStatusBarStyle(originalStatusBarStyle, animated: true)
        UIApplication.shared.wr_setStatusBarHidden(originalStatusBarVisibility, with: .fade)
    }

    override func dismiss(animated flag: Bool, completion defaultBlock: (() -> Void)? = nil) {
        super.dismiss(animated: flag) {
            self.onDismiss?()
            defaultBlock?()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }

}

extension BrowserViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        completion?()
    }
}
