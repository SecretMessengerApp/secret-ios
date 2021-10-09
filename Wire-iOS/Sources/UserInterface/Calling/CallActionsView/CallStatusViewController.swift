
import Foundation

final class CallStatusViewController: UIViewController {
    
    var configuration: CallStatusViewInputType {
        didSet {
            updateState()
        }
    }
    
    private let statusView: CallStatusView
    private weak var callDurationTimer: Timer?
    
    init(configuration: CallStatusViewInputType) {
        self.configuration = configuration
        statusView = CallStatusView(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        createConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateState()
    }
    
    deinit {
        stopCallDurationTimer()
    }
    
    private func setupViews() {
        statusView.accessibilityTraits = .header
        statusView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusView)
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusView.topAnchor.constraint(equalTo: view.topAnchor),
            statusView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func updateState() {
        statusView.configuration = configuration

        switch configuration.state {
        case .established: startCallDurationTimer()
        case .terminating: stopCallDurationTimer()
        default: break
        }
    }
    
    private func startCallDurationTimer() {
        stopCallDurationTimer()
        callDurationTimer = .scheduledTimer(withTimeInterval: 0.5, repeats: true) { [statusView, configuration] _ in
            statusView.configuration = configuration
        }
        RunLoop.current.add(callDurationTimer!, forMode: .common)
    }
    
    private func stopCallDurationTimer() {
        callDurationTimer?.invalidate()
        callDurationTimer = nil
    }
}
