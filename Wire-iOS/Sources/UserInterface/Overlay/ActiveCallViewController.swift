
import Foundation
import UIKit
import WireSystem
import WireDataModel

fileprivate let zmLog = ZMSLog(tag: "calling")

/// ViewController container for CallViewControllers. Displays the active the controller for active or incoming calls.
final class ActiveCallViewController : UIViewController {
    
    weak var dismisser: ViewControllerDismisser? {
        didSet {
            visibleVoiceChannelViewController.dismisser = dismisser
        }
    }
    
    var callStateObserverToken : Any?
    
    init(voiceChannel: VoiceChannel) {
        visibleVoiceChannelViewController = CallViewController(voiceChannel: voiceChannel)
        
        super.init(nibName: nil, bundle: nil)
        
        addChild(visibleVoiceChannelViewController)
        
        visibleVoiceChannelViewController.view.frame = view.bounds
        visibleVoiceChannelViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(visibleVoiceChannelViewController.view)
        visibleVoiceChannelViewController.didMove(toParent: self)
        
        zmLog.debug(String(format: "Presenting CallViewController: %p", visibleVoiceChannelViewController))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var visibleVoiceChannelViewController : CallViewController {
        didSet {
            transition(to: visibleVoiceChannelViewController, from: oldValue)
        }
    }
    
    override func loadView() {
        view = PassthroughTouchesView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let userSession = ZMUserSession.shared() else {
            zmLog.error("UserSession not available when initializing \(type(of: self))")
            return
        }
        
        callStateObserverToken = WireCallCenterV3.addCallStateObserver(observer: self, userSession: userSession)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateVisibleVoiceChannelViewController()
    }

    override var childForStatusBarStyle: UIViewController? {
        return visibleVoiceChannelViewController
    }
    
    override var childForStatusBarHidden: UIViewController? {
        return visibleVoiceChannelViewController
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let window = view.window
        super.dismiss(animated: flag) {
            completion?()
            (window as? CallWindow)?.hideWindowIfNeeded()
        }
    }

    func updateVisibleVoiceChannelViewController() {
        guard let conversation = ZMUserSession.shared()?.priorityCallConversation, visibleVoiceChannelViewController.conversation != conversation,
              let voiceChannel = conversation.voiceChannel else {
            return
        }
        
        visibleVoiceChannelViewController = CallViewController(voiceChannel: voiceChannel)
        visibleVoiceChannelViewController.dismisser = dismisser
    }
    
    func transition(to toViewController: UIViewController, from fromViewController: UIViewController) {
        guard toViewController != fromViewController else { return }
        
        zmLog.debug(String(format: "Transitioning to CallViewController: %p from: %p", toViewController, fromViewController))
        
        toViewController.view.frame = view.bounds
        toViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addChild(toViewController)
        
        transition(from: fromViewController,
                   to: toViewController,
                   duration: 0.35,
                   options: .transitionCrossDissolve,
                   animations: nil,
                   completion:
            { (finished) in
                toViewController.didMove(toParent: self)
                fromViewController.removeFromParent()
        })
    }
    
    var ongoingCallConversation : ZMConversation? {
        return ZMUserSession.shared()?.ongoingCallConversation
    }
    
}

extension ActiveCallViewController : WireCallCenterCallStateObserver {
    
    func callCenterDidChange(callState: CallState, conversation: ZMConversation, caller: UserType, timestamp: Date?, previousCallState: CallState?)  {
        updateVisibleVoiceChannelViewController()
    }
    
}
