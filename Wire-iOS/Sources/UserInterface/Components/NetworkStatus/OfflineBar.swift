
import Foundation
import Cartography

class OfflineBar: UIView {

    private let offlineLabel: UILabel
    private var aHeightConstraint: NSLayoutConstraint?

    var state: NetworkStatusViewState = .online {
        didSet {
            if oldValue != state {
                updateView()
            }
        }
    }

    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        offlineLabel = UILabel()

        super.init(frame: frame)
        backgroundColor = UIColor(hex:0xFEBF02, alpha: 1)

        layer.cornerRadius = CGFloat.OfflineBar.cornerRadius
        layer.masksToBounds = true

        offlineLabel.font = FontSpec(FontSize.small, .medium).font
        offlineLabel.textColor = UIColor.white
        offlineLabel.text = "system_status_bar.no_internet.title".localized(uppercased: true)

        addSubview(offlineLabel)

        createConstraints()
        updateView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        constrain(self, offlineLabel) { containerView, offlineLabel in
            offlineLabel.center == containerView.center
            offlineLabel.left >= containerView.leftMargin ~ 750
            offlineLabel.right <= containerView.rightMargin ~ 750

            aHeightConstraint = containerView.height == 0
        }
    }

    private func updateView() {
        switch state {
        case .online:
            aHeightConstraint?.constant = 0
            offlineLabel.alpha = 0
            layer.cornerRadius = 0
        case .onlineSynchronizing:
            aHeightConstraint?.constant = CGFloat.SyncBar.height
            offlineLabel.alpha = 0
            layer.cornerRadius = CGFloat.SyncBar.cornerRadius
        case .offlineExpanded:
            aHeightConstraint?.constant = CGFloat.OfflineBar.expandedHeight
            offlineLabel.alpha = 1
            layer.cornerRadius = CGFloat.OfflineBar.cornerRadius
        }
    }
}
