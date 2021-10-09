
import UIKit
import Cartography

public final class FeedbackOverlayView: UIView {

    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .smallSemiboldFont
        label.textColor = .dynamic(scheme: .title)
        return label
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        constrainViews()
        alpha = 0.0
        backgroundColor = .dynamic(scheme: .background)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func constrainViews() {
        constrain(self, titleLabel) { container, label in
            label.centerX == container.centerX
            label.centerY == container.centerY
            label.left >= container.left + 24
            label.right <= container.right - 24
        }
    }

    public func show(text: String) {
        titleLabel.text = text
        UIView.animateKeyframes(withDuration: 2, delay: 0, options: [], animations: {
            let fadeOutDuration = 0.015
            let fadeInDuration = 0.01
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: fadeInDuration) {
                self.alpha = 1.0
            }
            UIView.addKeyframe(withRelativeStartTime: 1 - fadeOutDuration, relativeDuration: fadeOutDuration) {
                self.alpha = 0.0
            }
        }, completion: nil)
    }
}
