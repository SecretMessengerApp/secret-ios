
import Foundation
import Cartography

class ContactsSectionHeaderView: UITableViewHeaderFooterView {
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .smallSemiboldFont
        label.textColor = .dynamic(scheme: .title)
        return label
    }()
    static let height: CGFloat = 20
    var sectionTitleLeftConstraint: NSLayoutConstraint!

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.backgroundColor = .clear

        backgroundView = blurEffectView

        setupSubviews()
        setupConstraints()
        setupStyle()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupSubviews() {

        contentView.addSubview(label)
    }

    func setupStyle() {
        self.textLabel?.isHidden = true
    }

    func setupConstraints() {

        constrain(label, self) { label, selfView in
            label.centerY == selfView.centerY
            label.leading == selfView.leading + 24
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: ContactsSectionHeaderView.height)
    }

}
