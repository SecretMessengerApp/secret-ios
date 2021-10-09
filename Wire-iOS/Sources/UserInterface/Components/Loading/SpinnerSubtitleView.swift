
import UIKit

 final class SpinnerSubtitleView: UIStackView {

    var subtitle: String? {
        didSet {
            updateSubtitle(subtitle)
        }
    }

    let spinner = ProgressSpinner()
    private let label = UILabel()

    init() {
        super.init(frame: .zero)
        setupViews()
        updateSubtitle(nil)
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        axis = .vertical
        alignment = .center
        spacing = 20
        distribution = .fillProportionally
        label.textColor = UIColor.from(scheme: .textForeground, variant: .dark)
        label.font = FontSpec(.small, .regular).fontWithoutDynamicType
        [spinner, label].forEach(addArrangedSubview)
    }

    private func updateSubtitle(_ text: String?) {
        label.text = text
        label.isHidden = nil == text || 0 == text!.count
    }

}
