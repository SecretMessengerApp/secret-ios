
import Foundation
import UIKit

protocol PermissionDeniedViewControllerDelegate: class {
    func continueWithoutPermission(_ viewController: PermissionDeniedViewController)
}

final class PermissionDeniedViewController: UIViewController {
    
    var backgroundBlurDisabled = false {
        didSet {
            backgroundBlurView.isHidden = backgroundBlurDisabled
        }
    }
    weak var delegate: PermissionDeniedViewControllerDelegate?
    
    private var initialConstraintsCreated = false
    private let heroLabel: UILabel = UILabel.createHeroLabel()
    private var settingsButton: Button!
    private var laterButton: UIButton!
    private let backgroundBlurView: UIVisualEffectView = UIVisualEffectView.createBackgroundBlurView()

    class func addressBookAccessDeniedViewController() -> PermissionDeniedViewController {
        let vc = PermissionDeniedViewController()
        let title = "registration.address_book_access_denied.hero.title".localized
        let paragraph1 = "registration.address_book_access_denied.hero.paragraph1".localized
        let paragraph2 = "registration.address_book_access_denied.hero.paragraph2".localized
        
        let text = [title, paragraph1, paragraph2].joined(separator: "\u{2029}")
        
        let attributedText = text.withCustomParagraphSpacing()

        attributedText.addAttributes([
            NSAttributedString.Key.font: UIFont.largeThinFont
            ], range: (text as NSString).range(of: [paragraph1, paragraph2].joined(separator: "\u{2029}")))
        attributedText.addAttributes([
            NSAttributedString.Key.font: UIFont.largeSemiboldFont
            ], range: (text as NSString).range(of: title))
        vc.heroLabel.attributedText = attributedText
        
        vc.settingsButton.setTitle("registration.address_book_access_denied.settings_button.title".localized.uppercased(), for: .normal)
        
        vc.laterButton.setTitle("registration.address_book_access_denied.maybe_later_button.title".localized.uppercased(), for: .normal)

        return vc
    }
    
    class func pushDeniedViewController() -> PermissionDeniedViewController {
        let vc = PermissionDeniedViewController()
        let title = "registration.push_access_denied.hero.title".localized
        let paragraph1 = "registration.push_access_denied.hero.paragraph1".localized
        
        let text = [title, paragraph1].joined(separator: "\u{2029}")
        
        let attributedText = text.withCustomParagraphSpacing()

        attributedText.addAttributes([
            NSAttributedString.Key.font: UIFont.largeThinFont
            ], range: (text as NSString).range(of: paragraph1))
        attributedText.addAttributes([
            NSAttributedString.Key.font: UIFont.largeSemiboldFont
            ], range: (text as NSString).range(of: title))
        vc.heroLabel.attributedText = attributedText
        
        vc.settingsButton.setTitle("registration.push_access_denied.settings_button.title".localized.uppercased(), for: .normal)
        
        vc.laterButton.setTitle("registration.push_access_denied.maybe_later_button.title".localized.uppercased(), for: .normal)
        
        return vc
    }
    
    required init() {
        super.init(nibName:nil, bundle:nil)

        view.addSubview(backgroundBlurView)
        backgroundBlurView.isHidden = backgroundBlurDisabled
        
        view.addSubview(heroLabel)
        createSettingsButton()
        createLaterButton()
        createConstraints()
        
        updateViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSettingsButton() {
        settingsButton = Button(style: .full)
        settingsButton.addTarget(self, action: #selector(openSettings(_:)), for: .touchUpInside)
        
        view.addSubview(settingsButton)
    }
    
    private func createLaterButton() {
        laterButton = UIButton(type: .custom)
        laterButton.titleLabel?.font = UIFont.smallLightFont
        laterButton.setTitleColor(UIColor.from(scheme: .textForeground, variant: .dark), for: .normal)
        laterButton.setTitleColor(UIColor.from(scheme: .buttonFaded, variant: .dark), for: .highlighted)
        laterButton.addTarget(self, action: #selector(continueWithoutAccess(_:)), for: .touchUpInside)
        
        view.addSubview(laterButton)
    }
    
    // MARK: - Actions
    @objc
    private func openSettings(_ sender: Any?) {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc
    private func continueWithoutAccess(_ sender: Any?) {
        delegate?.continueWithoutPermission(self)
    }

    
    private func createConstraints() {
        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
        backgroundBlurView.fitInSuperview()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()

        guard !initialConstraintsCreated else { return }

        initialConstraintsCreated = true

        [heroLabel, settingsButton, laterButton].forEach() {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }

        var constraints = heroLabel.fitInSuperview(with: EdgeInsets(margin: 28), exclude: [.top, .bottom], activate: false).map{$0.value}

        constraints += [settingsButton.topAnchor.constraint(equalTo: heroLabel.bottomAnchor, constant: 28),
                        settingsButton.heightAnchor.constraint(equalToConstant: 40)]

        constraints += settingsButton.fitInSuperview(with: EdgeInsets(margin: 28), exclude: [.top, .bottom], activate: false).map{$0.value}

        constraints += [laterButton.topAnchor.constraint(equalTo: settingsButton.bottomAnchor, constant: 28),
                        laterButton.pinToSuperview(safely: true, anchor: .bottom, inset: 28, activate: false),
                        laterButton.pinToSuperview(axisAnchor: .centerX, activate: false)]

        NSLayoutConstraint.activate(constraints)

    }
}

