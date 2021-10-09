

import UIKit
import Cartography
import TTTAttributedLabel


protocol UserNameTakeOverViewControllerDelegate: class {
    func takeOverViewController(_ viewController: UserNameTakeOverViewController, didPerformAction action: UserNameTakeOverViewControllerAction)
}


enum UserNameTakeOverViewControllerAction {
    case chooseOwn(String), keepSuggestion(String), learnMore
}

@objc
class UserNameTakeOverViewController: UIViewController {

    public let displayNameLabel = UILabel()
    public let suggestedHandleLabel = UILabel()
    public let subtitleLabel = TTTAttributedLabel(frame: .zero)

    private let chooseOwnButton = Button(style: .full)
    private let keepSuggestedButton = Button(style: .empty, variant: .light)
    private let contentView = UIView()
    private let topContainer = UIView()
    private let suggestedHandle: String
    private let name: String

    private let learnMore = "registration.select_handle.takeover.subtitle_link".localized
    fileprivate let learnMoreURL = URL(string:"action://learn-more")!

    weak var delegate: UserNameTakeOverViewControllerDelegate?

    init(suggestedHandle: String, name: String) {
        self.suggestedHandle = suggestedHandle
        self.name = name
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layoutMargins = UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28)
        setupViews()
        createConstraints()
    }

    func setupViews() {
        view.backgroundColor = .dynamic(scheme: .background)
        view.addSubview(contentView)
        [displayNameLabel, suggestedHandleLabel].forEach(topContainer.addSubview)
        [topContainer, subtitleLabel, chooseOwnButton, keepSuggestedButton].forEach(contentView.addSubview)
        
        displayNameLabel.font = FontSpec(.large, .thin).font!
        displayNameLabel.textColor = .dynamic(scheme: .title)
        displayNameLabel.text = name
        displayNameLabel.textAlignment = .center
        
        suggestedHandleLabel.font = FontSpec(.large, .none).font!
        suggestedHandleLabel.textColor = UIColor.dynamic(scheme: .subtitle)
        suggestedHandleLabel.text = "@" + suggestedHandle
        suggestedHandleLabel.textAlignment = .center

        chooseOwnButton.setTitle("registration.select_handle.takeover.choose_own".localized, for: .normal)
        keepSuggestedButton.setTitle("registration.select_handle.takeover.keep_suggested".localized, for: .normal)

        setupSubtitleLabel()

        [chooseOwnButton, keepSuggestedButton].forEach {
            $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        }
    }

    func setupSubtitleLabel() {
        subtitleLabel.textAlignment = .natural
        subtitleLabel.numberOfLines = 0
        subtitleLabel.linkAttributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle().rawValue as NSNumber]
        subtitleLabel.extendsLinkTouchArea = true
        
        let font = FontSpec(.large, .thin).font!
        let linkFont = FontSpec(.large, .none).font!
        let color = UIColor.dynamic(scheme: .title)

        let subtitle = "registration.select_handle.takeover.subtitle".localized
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: linkFont,
            .link: learnMoreURL
        ]

        let text = (subtitle && font && color) + " " + (learnMore && linkAttributes && color)
        subtitleLabel.attributedText = text
        subtitleLabel.addLinks()
        subtitleLabel.accessibilityLabel = text.string
        subtitleLabel.delegate = self
    }

    func createConstraints() {
        constrain(displayNameLabel, suggestedHandleLabel, topContainer) { nameLabel, handleLabel, container in
            nameLabel.leading == container.leading
            nameLabel.trailing == container.trailing
            nameLabel.bottom == container.centerY - 4
            handleLabel.leading == container.leading
            handleLabel.trailing == container.trailing
            handleLabel.top == container.centerY + 4
        }

        constrain(view, contentView, topContainer, subtitleLabel) { view, contentView, container, subtitleLabel in
            contentView.edges == view.edges
            container.top == contentView.topMargin
            container.leading == contentView.leading
            container.trailing == contentView.trailing
            container.bottom == subtitleLabel.top
            subtitleLabel.leading == contentView.leadingMargin
            subtitleLabel.trailing == contentView.trailingMargin
        }

        constrain(contentView, subtitleLabel, chooseOwnButton, keepSuggestedButton) { contentView, subtitleLabel, chooseButton, keepButton in
            subtitleLabel.bottom == chooseButton.top - 28
            chooseButton.leading == contentView.leadingMargin
            chooseButton.trailing == contentView.trailingMargin
            chooseButton.bottom == keepButton.top - 8
            chooseButton.height == 40
            keepButton.leading == contentView.leadingMargin
            keepButton.trailing == contentView.trailingMargin
            keepButton.bottom == contentView.bottomMargin - UIScreen.safeArea.bottom - 44
            keepButton.height == 40
        }
    }

    @objc func buttonTapped(sender: Button) {
        guard let action = action(for: sender) else { return }
        delegate?.takeOverViewController(self, didPerformAction: action)
    }

    private func action(for button: Button) -> UserNameTakeOverViewControllerAction? {
        switch button {
        case chooseOwnButton: return .chooseOwn(suggestedHandle)
        case keepSuggestedButton: return .keepSuggestion(suggestedHandle)
        default: return nil
        }
    }

}

extension UserNameTakeOverViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        guard url == learnMoreURL else { return }
        delegate?.takeOverViewController(self, didPerformAction: .learnMore)
    }
}
