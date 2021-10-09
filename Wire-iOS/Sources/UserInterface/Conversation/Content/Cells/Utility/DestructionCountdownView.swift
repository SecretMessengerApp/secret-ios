
import UIKit

final class DestructionCountdownView: UIView {

    private let remainingTimeLayer = CAShapeLayer()
    private let elapsedTimeLayer = CAShapeLayer()
    private let elapsedTimeAnimationKey = "elapsedTime"

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSublayers()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSublayers()
    }

    private func configureSublayers() {
        layer.addSublayer(remainingTimeLayer)
        layer.addSublayer(elapsedTimeLayer)

        elapsedTimeLayer.strokeEnd = 0
        elapsedTimeLayer.isOpaque = false
        remainingTimeLayer.isOpaque = false

        let background = UIColor.dynamic(scheme: .background)

        elapsedTimeColor = UIColor.lightGraphite
            .withAlphaComponent(0.24)
            .removeAlphaByBlending(with: background)

        remainingTimeColor = UIColor.lightGraphite.withAlphaComponent(0.64).removeAlphaByBlending(with: .white)
    }

    // MARK: - Layout

    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let backgroundFrame = bounds
        let borderWidth = 0.10 * backgroundFrame.width
        let elapsedFrame = bounds.insetBy(dx: borderWidth, dy: borderWidth)

        elapsedTimeLayer.frame = backgroundFrame
        elapsedTimeLayer.path = makePath(for: elapsedFrame)
        elapsedTimeLayer.fillColor = nil
        elapsedTimeLayer.lineWidth = min(elapsedFrame.width, elapsedFrame.height) / 2

        remainingTimeLayer.frame = backgroundFrame
        remainingTimeLayer.path = CGPath(ellipseIn: bounds, transform: nil)
    }

    private func makePath(for bounds: CGRect) -> CGPath {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: min(bounds.height, bounds.width) / 4, startAngle: -.pi / 2, endAngle: 3 * .pi / 2, clockwise: false)
        return path
    }

    // MARK: - Animation

    var isAnimatingProgress: Bool {
        return elapsedTimeLayer.animation(forKey: elapsedTimeAnimationKey) != nil
    }

    var remainingTimeColor: UIColor? {
        get {
            return remainingTimeLayer.fillColor.flatMap(UIColor.init)
        }
        set {
            remainingTimeLayer.fillColor = newValue?.cgColor
        }
    }

    var elapsedTimeColor: UIColor? {
        get {
            return elapsedTimeLayer.strokeColor.flatMap(UIColor.init)
        }
        set {
            elapsedTimeLayer.strokeColor = newValue?.withAlphaComponent(1).cgColor
            elapsedTimeLayer.opacity = Float(newValue?.alpha ?? CGFloat(0))
        }
    }

    func startAnimating(duration: TimeInterval, currentProgress: CGFloat) {

        let elapsedTimeAnimation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.strokeEnd))
        elapsedTimeAnimation.duration = duration
        elapsedTimeAnimation.fromValue = currentProgress
        elapsedTimeAnimation.toValue = 1
        elapsedTimeAnimation.fillMode = .forwards
        elapsedTimeAnimation.isRemovedOnCompletion = false

        elapsedTimeLayer.add(elapsedTimeAnimation, forKey: elapsedTimeAnimationKey)

    }

    @objc func stopAnimating() {
        elapsedTimeLayer.removeAllAnimations()
    }

    @objc func setProgress(_ newValue: CGFloat) {
        elapsedTimeLayer.strokeEnd = newValue
    }

}
