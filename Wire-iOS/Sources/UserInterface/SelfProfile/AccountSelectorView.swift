
import UIKit
import Cartography

protocol AccountSelectorViewDelegate: class {
    
    func accountSelectorDidSelect(account: Account)
    
}

internal class LineView: UIView {
    public let views: [UIView]
    init(views: [UIView]) {
        self.views = views
        super.init(frame: .zero)
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutViews() {
        
        self.views.forEach(self.addSubview)
        
        guard let first = self.views.first else {
            return
        }
        
        let inset: CGFloat = 6
        
        constrain(self, first) { selfView, first in
            first.leading == selfView.leading
            first.top == selfView.top
            first.bottom == selfView.bottom ~ 750.0
        }
        
        var previous: UIView = first
        
        self.views.dropFirst().forEach {
            constrain(previous, $0, self) { previous, current, selfView in
                current.leading == previous.trailing + inset
                current.top == selfView.top
                current.bottom == selfView.bottom
            }
            previous = $0
        }

        guard let last = self.views.last else {
            return
        }
        
        constrain(self, last) { selfView, last in
            last.trailing == selfView.trailing
        }
    }
}

final class AccountSelectorView: UIView {
    public weak var delegate: AccountSelectorViewDelegate? = nil
    
    private var selfUserObserverToken: NSObjectProtocol!
    private var applicationDidBecomeActiveToken: NSObjectProtocol!

    fileprivate var accounts: [Account]? = nil {
        didSet {
            guard let _ = ZMUserSession.shared() else {
                return
            }
            
            accountViews = accounts?.map({ AccountViewFactory.viewFor(account: $0, displayContext: .accountSelector) }) ?? []
            
            accountViews.forEach { (accountView) in
                
                accountView.unreadCountStyle = accountView.account.isActive ? .none : .current
                accountView.onTap = { [weak self] account in
                    guard let account = account else { return }
                    self?.delegate?.accountSelectorDidSelect(account: account)
                }
            }

            self.lineView = LineView(views: self.accountViews)
            self.topOffsetConstraint.constant = imagesCollapsed ? -20 : 0
            self.accountViews.forEach { $0.collapsed = imagesCollapsed }
        }
    }

    private var accountViews: [BaseAccountView] = []
    private var lineView: LineView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let newLineView = self.lineView {
                self.addSubview(newLineView)
                
                constrain(self, newLineView) { selfView, lineView in
                    self.topOffsetConstraint = lineView.centerY == selfView.centerY
                    lineView.leading == selfView.leading
                    lineView.trailing == selfView.trailing
                    lineView.height == selfView.height
                }
            }
        }
    }
    private var topOffsetConstraint: NSLayoutConstraint!
    public var imagesCollapsed: Bool = false {
        didSet {
            self.topOffsetConstraint.constant = imagesCollapsed ? -20 : 0
            
            self.accountViews.forEach { $0.collapsed = imagesCollapsed }
            
            self.layoutIfNeeded()
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        applicationDidBecomeActiveToken = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.update(with: SessionManager.shared?.accountManager.accounts)
        })
        
        self.update(with: SessionManager.shared?.accountManager.accounts)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func update(with accounts: [Account]?) {
        self.accounts = accounts
    }

}

private extension Account {
    
    var isActive: Bool {
        return SessionManager.shared?.accountManager.selectedAccount == self
    }
}
