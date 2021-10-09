

import UIKit
import Cartography


final class ArchivedNavigationBar: UIView {
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .separator)

        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .from(scheme: .textForeground, variant: .dark)
        label.font = .mediumSemiboldFont

        return label
    }()
    let dismissButton = IconButton()
    private let barHeight: CGFloat = 44
    private let statusbarHeight: CGFloat = 20

    var dismissButtonHandler: (()->())? = .none
    
    var showSeparator: Bool = false {
        didSet {
            separatorView.fadeAndHide(!showSeparator)
        }
    }
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        titleLabel.text = title
        createViews()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createViews() {
        titleLabel.accessibilityTraits.insert(.header)
        separatorView.isHidden = true
        dismissButton.setIcon(.cross, size: .tiny, for: [])
        dismissButton.addTarget(self, action: #selector(ArchivedNavigationBar.dismissButtonTapped(_:)), for: .touchUpInside)
        dismissButton.accessibilityIdentifier = "archiveCloseButton"
        dismissButton.accessibilityLabel = "general.close".localized
        dismissButton.setIconColor(.from(scheme: .textForeground, variant: .dark), for: .normal)
        [titleLabel, dismissButton, separatorView].forEach(addSubview)
    }
    
    func createConstraints() {
        constrain(self, separatorView, titleLabel, dismissButton) { view, separator, title, button in
            separator.height == .hairline
            separator.left == view.left
            separator.right == view.right
            separator.bottom == view.bottom
            
            title.centerX == view.centerX
            title.centerY == view.centerY
            
            button.centerY == title.centerY
            button.right == view.right - 16
            button.left >= title.right + 8
            
            view.height == barHeight
        }
    }
    
    @objc func dismissButtonTapped(_ sender: IconButton) {
        dismissButtonHandler?()
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: barHeight + statusbarHeight)
    }
    
}
