

import Foundation

enum IncomingConnectionAction: UInt {
    case ignore, accept
}

final class IncomingConnectionViewController: UIViewController {

    fileprivate var connectionView: IncomingConnectionView!

    let userSession: ZMUserSession!
    let user: ZMUser
    var onAction: ((IncomingConnectionAction) -> ())?

    init(userSession: ZMUserSession!, user: ZMUser) {
        self.userSession = userSession
        self.user = user
        super.init(nibName: .none, bundle: .none)

        guard !self.user.isConnected else { return }
        user.refreshData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.connectionView = IncomingConnectionView(user: user)
        self.connectionView.onAccept = { [weak self] user in
            guard let `self` = self else { return }
            self.userSession.performChanges {
                self.user.accept()
            }
            self.onAction?(.accept)
        }
        self.connectionView.onIgnore = { [weak self] user in
            guard let `self` = self else { return }
            self.userSession.performChanges {
                self.user.ignore()
            }

            self.onAction?(.ignore)
        }

        view = connectionView
    }
    
}

 final class UserConnectionViewController: UIViewController {

    fileprivate var userConnectionView: UserConnectionView!

    let userSession: ZMUserSession
    let user: ZMUser

    
    init(userSession: ZMUserSession, user: ZMUser) {
        self.userSession = userSession
        self.user = user
        super.init(nibName: .none, bundle: .none)
        
        guard !self.user.isConnected else { return }
        user.refreshData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.userConnectionView = UserConnectionView(user: self.user)
        self.view = self.userConnectionView
    }
}
