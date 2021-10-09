
import UIKit
import Cartography

final class DotView: UIView {
    
    fileprivate let circleView = ShapeView()
    fileprivate let centerView = ShapeView()
    private var userObserver: NSObjectProtocol!
    private var clientsObserverTokens: [NSObjectProtocol] = []
    private let user : ZMUser?
    public var hasUnreadMessages: Bool = false {
        didSet { self.updateIndicator() }
    }
    
    var showIndicator: Bool {
        set { self.isHidden = !newValue }
        get { return !self.isHidden }
    }
    
    init(user: ZMUser? = nil) {
        self.user = user
        super.init(frame: .zero)
        self.isHidden = true
        
        circleView.pathGenerator = {
            return UIBezierPath(ovalIn: CGRect(origin: .zero, size: $0))
        }
        circleView.hostedLayer.lineWidth = 0
        circleView.hostedLayer.fillColor = UIColor.white.cgColor
        
        centerView.pathGenerator = {
            return UIBezierPath(ovalIn: CGRect(origin: .zero, size: $0))
        }
        centerView.hostedLayer.fillColor = UIColor.accent().cgColor
        
        addSubview(circleView)
        addSubview(centerView)
        constrain(self, circleView, centerView) { selfView, backingView, centerView in
            backingView.edges == selfView.edges
            centerView.edges == inset(selfView.edges, 1, 1, 1, 1)
        }
        
        if let userSession = ZMUserSession.shared(), let user = user {
            userObserver = UserChangeInfo.add(observer: self, for: user, userSession: userSession)
        }
        
        self.createClientObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createClientObservers() {
        guard let user = user else { return }
        clientsObserverTokens = user.clients.map { UserClientChangeInfo.add(observer: self, for: $0) }
    }
    
    internal func updateIndicator() {
        showIndicator = hasUnreadMessages ||
                        user?.clientsRequiringUserAttention.count > 0 ||
                        user?.readReceiptsEnabledChangedRemotely == true
    }
}

extension DotView: ZMUserObserver {
    func userDidChange(_ changeInfo: UserChangeInfo) {
        
        guard changeInfo.trustLevelChanged ||
              changeInfo.clientsChanged ||
              changeInfo.accentColorValueChanged ||
              changeInfo.readReceiptsEnabledChanged ||
              changeInfo.readReceiptsEnabledChangedRemotelyChanged else { return }
        
        centerView.hostedLayer.fillColor = UIColor.accent().cgColor
        
        updateIndicator()
        
        if changeInfo.clientsChanged {
            createClientObservers()
        }
    }
}

// MARK: - Clients observer

extension DotView: UserClientObserver {
    func userClientDidChange(_ changeInfo: UserClientChangeInfo) {
        guard changeInfo.needsToNotifyUserChanged else { return }
        updateIndicator()
    }
}


