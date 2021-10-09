
import Foundation

protocol CallAccessoryViewControllerDelegate: class {
    func callAccessoryViewControllerDidSelectShowMore(viewController: CallAccessoryViewController)
}

final class CallAccessoryViewController: UIViewController, CallParticipantsViewControllerDelegate {
    
    weak var delegate: CallAccessoryViewControllerDelegate?
    private let participantsViewController: CallParticipantsViewController
    private let avatarView = UserImageViewContainer(size: .big, maxSize: 240, yOffset: -8)
    private let videoPlaceholderStatusLabel = UILabel(
        key: "video_call.camera_access.denied",
        size: .normal,
        weight: .semibold,
        color: .textForeground,
        variant: .dark
    )

    var configuration: CallInfoViewControllerInput {
        didSet {
            updateState()
        }
    }

    init(configuration: CallInfoViewControllerInput) {
        self.configuration = configuration
        participantsViewController = CallParticipantsViewController(participants: configuration.accessoryType.participants, allowsScrolling: false)
        super.init(nibName: nil, bundle: nil)
        participantsViewController.delegate = self
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = PassthroughTouchesView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        createConstraints()
        updateState()
    }

    private func setupViews() {
        addToSelf(participantsViewController)
        avatarView.isAccessibilityElement = false
        [avatarView, videoPlaceholderStatusLabel].forEach(view.addSubview)
        videoPlaceholderStatusLabel.alpha = 0.64
        videoPlaceholderStatusLabel.textAlignment = .center
    }

    private func createConstraints() {
        participantsViewController.view.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        videoPlaceholderStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        participantsViewController.view.fitInSuperview()
        avatarView.fitInSuperview()

        NSLayoutConstraint.activate([
            videoPlaceholderStatusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoPlaceholderStatusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoPlaceholderStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func updateState() {
        switch configuration.accessoryType {
        case .avatar(let user):
            avatarView.user = user
        case .participantsList(let participants):
            participantsViewController.variant = configuration.effectiveColorVariant
            participantsViewController.participants = participants
        case .none: break
        }

        avatarView.isHidden = !configuration.accessoryType.showAvatar
        participantsViewController.view.isHidden = !configuration.accessoryType.showParticipantList
        videoPlaceholderStatusLabel.isHidden = configuration.videoPlaceholderState != .statusTextDisplayed
    }
    
    func callParticipantsViewControllerDidSelectShowMore(viewController: CallParticipantsViewController) {
        delegate?.callAccessoryViewControllerDidSelectShowMore(viewController: self)
    }

}
