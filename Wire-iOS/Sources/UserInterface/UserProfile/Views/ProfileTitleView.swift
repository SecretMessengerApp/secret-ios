
import UIKit
import Cartography
import WireDataModel

final class ProfileTitleView: UIView {

    let verifiedImageView = UIImageView(image: WireStyleKit.imageOfShieldverified)
    private let titleLabel = UILabel()

    var showVerifiedShield = false {
        didSet {
            updateVerifiedShield()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        verifiedImageView.accessibilityIdentifier = "VerifiedShield"

        titleLabel.accessibilityIdentifier = "user_profile.name"
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(verifiedImageView)
    }

    private func createConstraints() {
        constrain(self, titleLabel, verifiedImageView) { container, titleLabel, verifiedImageView in
            titleLabel.top == container.top
            titleLabel.bottom == container.bottom
            titleLabel.leading == container.leading
            titleLabel.trailing == container.trailing

            verifiedImageView.centerY == titleLabel.centerY
            verifiedImageView.leading == titleLabel.trailing + 10
        }
    }

    func configure(with user: UserType, variant: ColorSchemeVariant) {
        let attributedTitle = user.nameIncludingAvailability(color: UIColor.from(scheme: .textForeground, variant: variant))
        titleLabel.attributedText = attributedTitle
        titleLabel.font = FontSpec(.normal, .medium).font!
    }

    private func updateVerifiedShield() {
        UIView.transition(
            with: verifiedImageView,
            duration: 0.2,
            options: .transitionCrossDissolve,
            animations: { self.verifiedImageView.isHidden = !self.showVerifiedShield }
        )
    }

}
