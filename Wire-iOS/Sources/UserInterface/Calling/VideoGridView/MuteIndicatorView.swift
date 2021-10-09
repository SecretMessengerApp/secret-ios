
import UIKit
import Cartography

extension UIColor {
    enum MuteIndicator {
        static let containerBackground = UIColor(hex: 0x33373A, alpha:0.4)
    }
}

extension CGFloat {
    enum MuteIndicator {
        static let containerHeight: CGFloat = 32
        static let containerHorizontalMargin: CGFloat = 12
        static let iconLabelSpacing: CGFloat = 8
    }
}


final class MuteIndicatorView: UIView {
    let mutedIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setIcon(.microphoneWithStrikethrough, size: 12, color: .white)
        return imageView
    }()

    let mutedLabel: TransformLabel = {
        let label = TransformLabel()
        label.font = .smallSemiboldFont
        label.textColor = .white
        label.text = "conversation.status.silenced".localized
        label.textTransform = .upper

        return label
    }()

    init() {
        super.init(frame: .zero)

        backgroundColor = UIColor.MuteIndicator.containerBackground
        layer.cornerRadius = CGFloat.MuteIndicator.containerHeight / 2
        layer.masksToBounds = true


        [mutedIconImageView, mutedLabel].forEach( addSubview )

        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createConstraints() {
        constrain(mutedIconImageView, mutedLabel, self) { mutedIconImageView, mutedLabel, containerView in

            mutedLabel.centerY == containerView.centerY
            mutedIconImageView.centerY == containerView.centerY

            mutedIconImageView.leading == containerView.leading + CGFloat.MuteIndicator.containerHorizontalMargin
            mutedIconImageView.trailing == mutedLabel.leading - CGFloat.MuteIndicator.iconLabelSpacing
            mutedLabel.trailing == containerView.trailing - CGFloat.MuteIndicator.containerHorizontalMargin

        }
    }
}

