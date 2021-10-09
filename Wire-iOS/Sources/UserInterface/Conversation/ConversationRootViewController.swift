
import Foundation
import Cartography

// This class wraps the conversation content view controller in order to display the navigation bar on the top
class ConversationRootViewController: UIViewController {

    var navHeight: NSLayoutConstraint?
    var networkStatusBarHeight: NSLayoutConstraint?

    /// for NetworkStatusViewDelegate
    var shouldAnimateNetworkStatusView = false
    fileprivate var contentView = UIView()
    
    weak var expandDelegate: ConversationRootViewControllerExpandDelegate?

    fileprivate let networkStatusViewController: NetworkStatusViewController

    weak var conversationViewController: ConversationViewController?
    
    var conversation: ZMConversation
    var visibleMessage: ZMConversationMessage?
    weak var clientViewController: ZClientViewController?
    private var token: AnyObject?

    var topAppNeedUpdate = false

    var allAppNeedUpdate = false
    
    weak var splitviewcontroller: SplitViewController?

    var blockedAlertView: AlertView?

    var scrollToApp: String?
    
    deinit {
        debugPrint("ConversationRootViewController   deinit")
    }
    
    init(conversation: ZMConversation, message: ZMConversationMessage?, clientViewController: ZClientViewController, scrollToApp: String? = nil) {
        self.conversation = conversation
        self.visibleMessage = message
        self.clientViewController = clientViewController
        self.splitviewcontroller = clientViewController.children.first as? SplitViewController
        self.scrollToApp = scrollToApp
        
        networkStatusViewController = NetworkStatusViewController()

        super.init(nibName: .none, bundle: .none)
        
        networkStatusViewController.delegate = self

        let conversationController = ConversationViewController(session: ZMUserSession.shared()!, conversation: self.conversation, visibleMessage: nil, zClientViewController: clientViewController)
        
        conversationViewController = conversationController
        addChild(conversationController)
        contentView.addSubview(conversationController.view)
        conversationController.didMove(toParent: self)

        self.addToSelf(networkStatusViewController)
        let tempView = UIView()
        view.addSubview(tempView)
        configure()
        networkStatusViewController.createConstraintsInParentController(bottomView: tempView, controller: self)
        
        self.token = ConversationChangeInfo.add(observer: self, for: self.conversation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let conversationViewController = self.conversationViewController else {
            return
        }
        self.view.backgroundColor = UIColor.from(scheme: .barBackground)
        self.view.addSubview(self.contentView)
        [contentView,
         conversationViewController.view
        ].forEach { (view) in
            view?.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([

            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),

            conversationViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            conversationViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            conversationViewController.view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            conversationViewController.view.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        delay(0.4) {
            UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
        }
        
        shouldAnimateNetworkStatusView = true
        self.conversation.markAsRead()
        
        self.handleIfBlocked()
    }
    
    @objc (scrollToMessage:)
    func scroll(to message: ZMConversationMessage) {
        conversationViewController?.scroll(to: message)
    }
    
    lazy var cover: UIButton = {
        let cover = UIButton.init(type: .custom)
        cover.backgroundColor = UIColor.init(white: 0.3, alpha: 0.8)
        cover.frame = self.view.bounds
        cover.addTarget(self, action: #selector(groupsDismiss), for: .allTouchEvents)
        return cover
    }()
}


extension ConversationRootViewController: NetworkStatusBarDelegate {
    var bottomMargin: CGFloat {
        return CGFloat.NetworkStatusBar.bottomMargin
    }

    func showInIPad(networkStatusViewController: NetworkStatusViewController, with orientation: UIInterfaceOrientation) -> Bool {
        // always show on iPad for any orientation in regular mode
        return true
    }
}

