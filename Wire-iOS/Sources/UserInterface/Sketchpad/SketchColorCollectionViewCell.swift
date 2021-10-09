import UIKit

final class SketchColorCollectionViewCell: UICollectionViewCell {
    var sketchColor: UIColor? {
        didSet {
            guard sketchColor != oldValue else {
                return
            }

            if let sketchColor = sketchColor {
                knobView.knobColor = sketchColor
            }
        }
    }

    var brushWidth: CGFloat = 6 {
        didSet {
            guard brushWidth != oldValue else {
                return
            }

            knobView.knobDiameter = brushWidth
            knobView.setNeedsLayout()
        }
    }

    override var isSelected: Bool {
        didSet {
            knobView.knobColor = sketchColor
            knobView.isSelected = isSelected
        }
    }

    private var knobView: ColorKnobView!
    private var initialContraintsCreated = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        knobView = ColorKnobView()
        addSubview(knobView)

        setNeedsUpdateConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateConstraints() {
        super.updateConstraints()

        if initialContraintsCreated {
            return
        }

        knobView.translatesAutoresizingMaskIntoConstraints = false
        knobView.centerInSuperview()
        knobView.setDimensions(length: 25)

        initialContraintsCreated = true
    }
}
