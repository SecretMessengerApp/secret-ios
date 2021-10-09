

import Foundation

protocol ViewControllerDismisser: class {
    func dismiss(viewController: UIViewController, completion: (()->Void)?)
}
