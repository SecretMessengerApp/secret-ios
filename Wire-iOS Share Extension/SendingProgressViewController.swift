
import Foundation
import WireCommonComponents
import WireShareEngine
import Cartography
import SystemConfiguration
import WireSystem
import UIKit

final class SendingProgressViewController : UIViewController {

    enum ProgressMode {
        case preparing, sending
    }

    var cancelHandler : (() -> Void)?
    
    private var circularShadow = CircularProgressView()
    private var circularProgress = CircularProgressView()
    private var connectionStatusLabel = UILabel()
    private let minimumProgress : Float = 0.125
    
    var progress: Float = 0 {
        didSet {
            mode = .sending
            let adjustedProgress = (progress / (1 + minimumProgress)) + minimumProgress
            circularProgress.setProgress(adjustedProgress, animated: true)
        }
    }

    var mode: ProgressMode = .preparing {
        didSet {
            updateProgressMode()
        }
    }

    func updateProgressMode() {
        switch mode {
        case .sending:
            circularProgress.deterministic = true
            self.title = "share_extension.sending_progress.title".localized
        case .preparing:
            circularProgress.deterministic = false
            circularProgress.setProgress(minimumProgress, animated: false)
            self.title = "share_extension.preparing.title".localized
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelTapped))
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(SendingProgressViewController.networkStatusDidChange(_:)),
                                               name: Notification.Name.NetworkStatus,
                                               object: nil)
        
        circularShadow.lineWidth = 2
        circularShadow.setProgress(1, animated: false)
        circularShadow.alpha = 0.2
        
        circularProgress.lineWidth = 2
        circularProgress.setProgress(0, animated: false)
        
        connectionStatusLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        connectionStatusLabel.textAlignment = .center
        connectionStatusLabel.isHidden = true
        connectionStatusLabel.text = "share_extension.no_internet_connection.title".localized
        
        view.addSubview(circularShadow)
        view.addSubview(circularProgress)
        view.addSubview(connectionStatusLabel)
        
        constrain(view, circularShadow, circularProgress, connectionStatusLabel) {
            container, circularShadow, circularProgress, connectionStatus in
            circularShadow.width == 48
            circularShadow.height == 48
            circularShadow.center == container.center
            
            circularProgress.width == 48
            circularProgress.height == 48
            circularProgress.center == container.center
            
            connectionStatus.bottom == container.bottom - 5
            connectionStatus.centerX == container.centerX
        }

        updateProgressMode()
        
        let reachability = NetworkStatus.shared.reachability
        setReachability(from: reachability)
    }
    
    @objc func onCancelTapped() {
        cancelHandler?()
    }
    
    @objc
    private func networkStatusDidChange(_ notification: Notification) {
        if let status = notification.object as? NetworkStatus {
            setReachability(from: status.reachability)
        }
    }
    
    func setReachability(from reachability: ServerReachability) {
        switch reachability {
            case .ok:
                connectionStatusLabel.isHidden = true
            case .unreachable:
                connectionStatusLabel.isHidden = false
        }
    }

}
