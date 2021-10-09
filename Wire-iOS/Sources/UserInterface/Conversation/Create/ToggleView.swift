//
import UIKit
import Cartography

final class ToggleView: UIView, Themeable {
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant  = ColorScheme.default.variant {
        didSet {
            guard colorSchemeVariant != oldValue else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    typealias ToggleHandler = (Bool) -> Void
    private let toggle = UISwitch()
    private let titleLabel = UILabel()
    private let title: String
    
    var handler: ToggleHandler?
    var isOn: Bool {
        set { toggle.isOn = newValue }
        get { return toggle.isOn }
    }
    
    init(title: String, isOn: Bool, accessibilityIdentifier: String) {
        self.title = title
        super.init(frame: .zero)
        setupViews()
        applyColorScheme(colorSchemeVariant)
        createConstraints()
        toggle.isOn = isOn
        toggle.accessibilityIdentifier = accessibilityIdentifier
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        [toggle, titleLabel].forEach(addSubview)
        titleLabel.text = title
        titleLabel.font = FontSpec(.normal, .light).font!
        toggle.addTarget(self, action: #selector(toggleValueChanged), for: .valueChanged)
    }

    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        backgroundColor = UIColor.from(scheme: .barBackground, variant: colorSchemeVariant)
        titleLabel.textColor = UIColor.dynamic(scheme: .title)
    }
    
    private func createConstraints() {
        constrain(self, titleLabel, toggle) { view, titleLabel, toggle in
            titleLabel.centerY == view.centerY
            titleLabel.leading == view.leading + 16
            toggle.centerY == view.centerY
            toggle.trailing == view.trailing - 16
            view.height == 56
        }
    }
    
    @objc private func toggleValueChanged(_ sender: UISwitch) {
        handler?(sender.isOn)
    }
    
}
