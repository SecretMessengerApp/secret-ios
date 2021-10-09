
import UIKit


final class ConnectRequestCell: UITableViewCell {

    var acceptBlock: (() -> Void)?
    var ignoreBlock: (() -> Void)?

    private var connectRequestViewController: IncomingConnectionViewController?

    var user: ZMUser! {
        didSet {
            connectRequestViewController?.view.removeFromSuperview()

            let incomingConnectionViewController = IncomingConnectionViewController(userSession: ZMUserSession.shared(), user: user)

            incomingConnectionViewController.onAction = {[weak self] action in
                switch action {
                case .accept:
                    self?.acceptBlock?()
                case .ignore:
                    self?.ignoreBlock?()
                }
            }

            let view = incomingConnectionViewController.view!

            contentView.addSubview(view)

            view.translatesAutoresizingMaskIntoConstraints = false
            view.pinToSuperview(axisAnchor: .centerX)
            view.fitInSuperview()
            view.widthAnchor.constraint(lessThanOrEqualToConstant: 420)

            connectRequestViewController = incomingConnectionViewController
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
