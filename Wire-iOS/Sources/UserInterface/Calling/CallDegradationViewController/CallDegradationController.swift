
import Foundation

enum CallDegradationState: Equatable {
    
    case none
    case incoming(degradedUser: ZMUser?)
    case outgoing(degradedUser: ZMUser?)
    
}

protocol CallDegradationControllerDelegate: class {
    
    func continueDegradedCall()
    func cancelDegradedCall()
    
}

class CallDegradationController: UIViewController {

    weak var delegate: CallDegradationControllerDelegate? = nil
    weak var targetViewController: UIViewController? = nil
    var visisibleAlertController: UIAlertController? = nil
    
    // Used to delay presentation of the alert controller until
    // the view is ready.
    private var viewIsReady = false
    
    var state: CallDegradationState = .none {
        didSet {
            guard oldValue != state else { return }
            
            updateState()
        }
    }
        
    fileprivate func updateState() {
        switch state {
        case .none:
            visisibleAlertController?.dismiss(animated: true)
            visisibleAlertController = nil
        case .incoming(degradedUser: let degradedUser):
            visisibleAlertController = UIAlertController.degradedCall(degradedUser: degradedUser)
        case .outgoing(degradedUser: let degradeduser):
            visisibleAlertController = UIAlertController.degradedCall(degradedUser: degradeduser, confirmationBlock: { [weak self] (continueDegradedCall) in
                continueDegradedCall ? self?.delegate?.continueDegradedCall(): self?.delegate?.cancelDegradedCall()
            })
        }
        
        presentAlertIfNeeded()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewIsReady = true
        presentAlertIfNeeded()  
    }
    
    private func presentAlertIfNeeded() {
        guard
            viewIsReady,
            let alertViewController = visisibleAlertController,
            !alertViewController.isBeingPresented
            else { return }
        
        Log.calling.debug("Presenting alert about degraded call")
        targetViewController?.present(alertViewController, animated: !ProcessInfo.processInfo.isRunningTests)
    }
    
}

fileprivate extension UIAlertController {
    
    static func degradedCall(degradedUser: ZMUser?, confirmationBlock: ((_ continueDegradedCall: Bool) -> Void)? = nil) -> UIAlertController {
        
        let message: String
        if let degradedUser = degradedUser {
            if degradedUser.isSelfUser {
                message = "call.degraded.alert.message.self".localized
            } else {
                message = "call.degraded.alert.message.user".localized(args: degradedUser.displayName)
            }
        } else {
            message = "call.degraded.alert.message.unknown".localized
        }
        
        let controller =  UIAlertController(title: "call.degraded.alert.title".localized, message: message, preferredStyle: .alert)
        
        if let confirmationBlock = confirmationBlock {
            controller.addAction(UIAlertAction(title: "general.cancel".localized, style: .cancel) { (action) in
                confirmationBlock(false)
            })
            
            controller.addAction(UIAlertAction(title: "call.degraded.alert.action.continue".localized, style: .default) { (action) in
                confirmationBlock(true)
            })
        } else {
            controller.addAction(UIAlertAction(title: "general.ok".localized, style: .default))
        }
        
        return controller
    }
    
}
