
import Foundation

final class NetworkConditionIndicatorView: UIView, RoundedViewProtocol {

    private let label = UILabel()

    public override class var layerClass: AnyClass {
        return ContinuousMaskLayer.self
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 32)
    }

    init() {
        super.init(frame: .zero)
        isAccessibilityElement = true
        shouldGroupAccessibilityChildren = true

        backgroundColor = UIColor.nameColor(for: .brightOrange, variant: .light)
        shape = .relative(multiplier: 1, dimension: .height)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.firstBaselineAnchor.constraint(equalTo: centerYAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        backgroundColor = UIColor.nameColor(for: .brightOrange, variant: .light)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var networkQuality: NetworkQuality = .normal {
        didSet {
            label.attributedText = networkQuality.attributedString(color: .white)
            accessibilityLabel = "conversation.status.poor_connection".localized
            layoutIfNeeded()
        }
    }
}
