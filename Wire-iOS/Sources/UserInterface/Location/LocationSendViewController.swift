// 


import Cartography

protocol LocationSendViewControllerDelegate: class {
    func locationSendViewControllerSendButtonTapped(_ viewController: LocationSendViewController)
}

final class LocationSendViewController: UIViewController {
    
    let sendButton = Button(style: .full)
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = .normalFont
        label.textColor = .dynamic(scheme: .title)
        return label
    }()
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .separator)
        return view
    }()
    fileprivate let containerView = UIView()
    
    weak var delegate: LocationSendViewControllerDelegate?
    
    var address: String? {
        didSet {
            addressLabel.text = address
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        createConstraints()

        view.backgroundColor = .dynamic(scheme: .background)
    }
    
    fileprivate func configureViews() {
        sendButton.setTitle("location.send_button.title".localized(uppercased: true), for: [])
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.accessibilityIdentifier = "sendLocation"
        addressLabel.accessibilityIdentifier = "selectedAddress"
        view.addSubview(containerView)
        [addressLabel, sendButton, separatorView].forEach(containerView.addSubview)
    }

    fileprivate func createConstraints() {
        constrain(view, containerView, separatorView, addressLabel, sendButton) { view, container, separator, label, button in
            container.edges == inset(view.edges, 24, 0)
            label.leading == container.leading
            label.trailing <= button.leading - 12 ~ 1000.0
            label.top == container.top
            label.bottom == container.bottom - UIScreen.safeArea.bottom
            button.trailing == container.trailing
            button.centerY == label.centerY
            button.height == 28
            separator.leading == view.leading
            separator.trailing == view.trailing
            separator.top == container.top
            separator.height == .hairline
        }
        
        sendButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        addressLabel.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 750), for: .horizontal)
    }
    
    @objc fileprivate func sendButtonTapped(_ sender: Button) {
        delegate?.locationSendViewControllerSendButtonTapped(self)
    }
}
