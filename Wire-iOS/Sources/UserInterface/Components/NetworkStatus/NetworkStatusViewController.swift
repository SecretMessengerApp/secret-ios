
import Foundation
import Cartography

typealias NetworkStatusBarDelegate = NetworkStatusViewControllerDelegate & NetworkStatusViewDelegate

protocol NetworkStatusViewControllerDelegate: class {

    ///  return false if NetworkStatusViewController will not disapper in iPad regular mode with specific orientation.
    ///
    /// - networkStatusViewController: caller of this delegate method
    /// - Parameter orientation: orientation to check
    /// - Returns: return false if the class conform this protocol does not show NetworkStatusViewController in certain orientation.
    func showInIPad(networkStatusViewController: NetworkStatusViewController, with orientation: UIInterfaceOrientation) -> Bool
}

final class NetworkStatusViewController : UIViewController {

    weak var delegate: NetworkStatusBarDelegate? {
        didSet {
            networkStatusView.delegate = delegate
        }
    }

    let networkStatusView = NetworkStatusView()
    fileprivate var networkStatusObserverToken: Any?
    fileprivate var pendingState: NetworkStatusViewState?
    var state: NetworkStatusViewState?
    fileprivate var finishedViewWillAppear: Bool = false

    fileprivate var device: DeviceProtocol = UIDevice.current
    fileprivate var application: ApplicationProtocol = UIApplication.shared
    /// default init method with a parameter for injecting mock device and mock application
    ///
    /// - Parameter device: Provide this param for testing only
    /// - Parameter application: Provide this param for testing only
    convenience init(device: DeviceProtocol = UIDevice.current, application: ApplicationProtocol = UIApplication.shared) {
        self.init(nibName: nil, bundle: nil)

        self.device = device
        self.application = application
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        NotificationCenter.default.addObserver(self, selector: #selector(updateStateForIPad), name: UIApplication.didChangeStatusBarOrientationNotification, object: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applyPendingState), object: nil)
        NotificationCenter.default.removeObserver(self)
    }

    override func loadView() {
        let passthroughTouchesView = PassthroughTouchesView()
        passthroughTouchesView.clipsToBounds = true
        self.view = passthroughTouchesView
    }

    override func viewDidLoad() {
        view.addSubview(networkStatusView)

        constrain(self.view, networkStatusView) { containerView, networkStatusView in
            networkStatusView.leading == containerView.leading
            networkStatusView.trailing == containerView.trailing
            networkStatusView.top == containerView.top
            networkStatusView.height == containerView.height
        }

        if let userSession = ZMUserSession.shared() {
            enqueue(state: viewState(from: userSession.networkState))
            networkStatusObserverToken = ZMNetworkAvailabilityChangeNotification.addNetworkAvailabilityObserver(self, userSession: userSession)
        }

        networkStatusView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedOnNetworkStatusBar)))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard !finishedViewWillAppear else { return }

        finishedViewWillAppear = true
        if let userSession = ZMUserSession.shared() {
            enqueue(state: viewState(from: userSession.networkState))
        }
    }

    func createConstraintsInParentController(bottomView: UIView, controller: UIViewController) {
        constrain(bottomView, controller.view, view) { bottomView, containerView, networkStatusViewControllerView in
            networkStatusViewControllerView.leading == containerView.leading
            networkStatusViewControllerView.trailing == containerView.trailing
            bottomView.top == networkStatusViewControllerView.bottom
        }
        
        view.topAnchor.constraint(equalTo: controller.safeTopAnchor).isActive = true
    }

    func showOfflineAlert() {
        let offlineAlert = UIAlertController(
            title: "system_status_bar.no_internet.title".localized,
            message: "system_status_bar.no_internet.explanation".localized,
            alertAction: .confirm()
        )
        offlineAlert.presentTopmost()
    }

    fileprivate func viewState(from networkState: ZMNetworkState) -> NetworkStatusViewState {
        switch networkState {
        case .offline:
            return .offlineExpanded
        case .online:
            return .online
        case .onlineSynchronizing:
            return .onlineSynchronizing
        @unknown default:
            ///TODO: ZMNetworkState change to NS_CLOSED_ENUM 
            fatalError()
        }
    }

    @objc func tappedOnNetworkStatusBar() {
        switch networkStatusView.state {
        case .offlineExpanded:
            showOfflineAlert()
        default:
            break
        }
    }

    fileprivate func enqueue(state: NetworkStatusViewState) {
        pendingState = state
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(applyPendingState), object: nil)

        perform(#selector(applyPendingState), with: nil, afterDelay: 1)
    }

    @objc internal func applyPendingState() {
        guard let state = pendingState else { return }
        update(state: state)
        pendingState = nil
    }

    func update(state: NetworkStatusViewState) {
        self.state = state
        guard shouldShowOnIPad() else { return }

        networkStatusView.update(state: state, animated: true)
    }
}

extension NetworkStatusViewController: ZMNetworkAvailabilityObserver {
    func didChangeAvailability(newState: ZMNetworkState) {
        enqueue(state: viewState(from: newState))
    }
}

// MARK: - iPad size class and orientation switching

extension NetworkStatusViewController {
    func shouldShowOnIPad() -> Bool {
        guard isIPadRegular(device: device) else { return true }
        guard let delegate = self.delegate else { return true }

        let newOrientation = application.statusBarOrientation

        return delegate.showInIPad(networkStatusViewController: self, with: newOrientation)
    }

    @objc func updateStateForIPad() {
        guard device.userInterfaceIdiom == .pad else { return }
        guard let state = self.state else { return }

        switch self.traitCollection.horizontalSizeClass {
        case .regular:
            if shouldShowOnIPad() {
                networkStatusView.update(state: state, animated: false)
            } else {
                /// when size class changes and delegate view controller disabled to show networkStatusView, hide the networkStatusView
                networkStatusView.update(state: .online, animated: false)
            }
        case .compact, .unspecified:
            networkStatusView.update(state: state, animated: false)
        @unknown default:
            networkStatusView.update(state: state, animated: false)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateStateForIPad()
    }
}
