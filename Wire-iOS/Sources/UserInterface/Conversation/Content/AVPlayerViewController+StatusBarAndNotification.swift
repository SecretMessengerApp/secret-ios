
import Foundation
import AVKit

extension Notification.Name {
    static let dismissingAVPlayer = Notification.Name("DismissingAVPlayer")
}

extension AVPlayerViewController {
    override open var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard self.isBeingDismissed else {
            return
        }

        NotificationCenter.default.post(name: .dismissingAVPlayer, object: self)
    }
}

