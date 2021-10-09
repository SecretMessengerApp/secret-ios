
import Foundation

final class UserClientCell: SeparatorCollectionViewCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    private let deviceTypeIconView = ThemedImageView()
    private let accessoryIconView = ThemedImageView()
    private let verifiedIconView = UIImageView()

    private var contentStackView : UIStackView!
    private var titleStackView : UIStackView!
    private var iconStackView : UIStackView!
    
    private let boldFingerprintFont: UIFont = .smallSemiboldFont
    private let fingerprintFont: UIFont = .smallFont
    
    private weak var client: UserClientType? = nil
    
    override func setUp() {
        super.setUp()

        accessibilityIdentifier = "device_cell"
        shouldGroupAccessibilityChildren = true

        deviceTypeIconView.image = StyleKitIcon.devices.makeImage(size: .tiny, color: .dynamic(scheme: .iconNormal))
        deviceTypeIconView.translatesAutoresizingMaskIntoConstraints = false
        deviceTypeIconView.contentMode = .center

        verifiedIconView.image = WireStyleKit.imageOfShieldverified
        verifiedIconView.translatesAutoresizingMaskIntoConstraints = false
        verifiedIconView.contentMode = .center
        verifiedIconView.isAccessibilityElement = true
        verifiedIconView.accessibilityIdentifier = "device_cell.verifiedShield"

        accessoryIconView.translatesAutoresizingMaskIntoConstraints = false
        accessoryIconView.contentMode = .center

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .smallSemiboldFont
        titleLabel.accessibilityIdentifier = "device_cell.name"
        
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .smallRegularFont
        subtitleLabel.accessibilityIdentifier = "device_cell.identifier"
        
        iconStackView = UIStackView(arrangedSubviews: [verifiedIconView, accessoryIconView])
        iconStackView.spacing = 16
        iconStackView.axis = .horizontal
        iconStackView.distribution = .fill
        iconStackView.alignment = .center
        iconStackView.translatesAutoresizingMaskIntoConstraints = false
        iconStackView.setContentHuggingPriority(.required, for: .horizontal)
        
        titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        titleStackView.spacing = 4
        titleStackView.axis = .vertical
        titleStackView.distribution = .equalSpacing
        titleStackView.alignment = .leading
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView = UIStackView(arrangedSubviews: [deviceTypeIconView, titleStackView, iconStackView])
        contentStackView.axis = .horizontal
        contentStackView.distribution = .fill
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(contentStackView)
        
        createConstraints()
    }
    
    private func createConstraints() {
        NSLayoutConstraint.activate([
            deviceTypeIconView.widthAnchor.constraint(equalToConstant: 64),
            deviceTypeIconView.heightAnchor.constraint(equalToConstant: 64),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        
        backgroundColor = contentBackgroundColor(for: colorSchemeVariant)
        accessoryIconView.setIcon(.disclosureIndicator, size: .like, color: .dynamic(scheme: .accessory))
        titleLabel.textColor = .dynamic(scheme: .title)
        subtitleLabel.textColor = .dynamic(scheme: .title)
        
        updateDeviceIcon()
    }
    
    func configure(with client: UserClientType) {
        self.client = client
        
        let attributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: fingerprintFont.monospaced()]
        let boldAttributes: [NSAttributedString.Key: AnyObject] = [NSAttributedString.Key.font: boldFingerprintFont.monospaced()]
        
        verifiedIconView.image = client.verified ? WireStyleKit.imageOfShieldverified : WireStyleKit.imageOfShieldnotverified
        verifiedIconView.accessibilityLabel = client.verified ? "device.verified".localized : "device.not_verified".localized

        titleLabel.text = client.deviceClass?.localizedDescription.localizedUppercase ?? client.type.localizedDescription.localizedUppercase
        subtitleLabel.attributedText = client.attributedRemoteIdentifier(attributes, boldAttributes: boldAttributes, uppercase: true)
        
        updateDeviceIcon()
    }
    
    private func updateDeviceIcon() {
        switch client?.deviceClass {
        case .legalHold?:
            deviceTypeIconView.image = StyleKitIcon.legalholdactive.makeImage(size: .tiny, color: .vividRed)
            deviceTypeIconView.accessibilityIdentifier = "img.device_class.legalhold"
        default:
            deviceTypeIconView.setIcon(.devices, size: .tiny, color: .dynamic(scheme: .iconNormal))
            deviceTypeIconView.accessibilityIdentifier = client?.deviceClass == .desktop ? "img.device_class.desktop" : "img.device_class.phone"
        }
    }
}
