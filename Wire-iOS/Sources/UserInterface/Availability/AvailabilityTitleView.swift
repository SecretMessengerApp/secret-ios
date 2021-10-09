
import UIKit

/**
 * A title view subclass that displays the availability of the user.
 */

class AvailabilityTitleView: TitleView, Themeable, ZMUserObserver {
    
    /// The available options for this view.
    struct Options: OptionSet {
        let rawValue: Int
        
        /// Whether we allow the user to update the status by tapping this view.
        static let allowSettingStatus = Options(rawValue: 1 << 0)
        
        /// Whether to hide the action hint (down arrow) next to the status.
        static let hideActionHint = Options(rawValue: 1 << 1)
        
        /// Whether to display the user name instead of the availability.
        static let displayUserName = Options(rawValue: 1 << 2)
        
        /// Whether to use a large text font instead of the default small one.
        static let useLargeFont = Options(rawValue: 1 << 3)
        
        /// The default options for using the view in a title bar.
        static var header: Options = [.allowSettingStatus, .hideActionHint, .displayUserName, .useLargeFont]

    }
    
    // MARK: - Properties
    
    private let user: UserType
    private var observerToken: Any?
    private var options: Options
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard colorSchemeVariant != oldValue else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    // MARK: - Initialization
    
    /**
     * Creates a view for the specific user and options.
     * - parameter user: The user to display the availability of.
     * - parameter options: The options to display the availability.
     */
    
    init(user: UserType, options: Options) {
        self.options = options
        self.user = user
        
        super.init()
        
        if let sharedSession = ZMUserSession.shared() {
            self.observerToken = UserChangeInfo.add(observer: self, for: user, userSession: sharedSession)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil)
        
        updateConfiguration()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        updateConfiguration()
    }
    
    /// Refreshes the content and appearance of the view.
    private func updateConfiguration() {
        updateAppearance()
        updateContent()
    }
    
    /// Refreshes the content of the view, based on the user data and the options.
    private func updateContent() {
        let availability = user.availability
        let fontStyle: FontSize = options.contains(.useLargeFont) ? .normal : .small
        let icon = AvailabilityStringBuilder.icon(for: availability, with: self.titleColor!, and: fontStyle)
        let isInteractive = options.contains(.allowSettingStatus)
        var title = ""
        
        if options.contains(.displayUserName) {
            title = user.name ?? ""
        } else if availability == .none && options.contains(.allowSettingStatus) {
            title = "availability.message.set_status".localized(uppercased: true)
        } else if availability != .none {
            title = availability.localizedName.localizedUppercase
        }
        
        let showInteractiveIcon = isInteractive && !options.contains(.hideActionHint)
        super.configure(icon: icon, title: title, interactive: isInteractive, showInteractiveIcon: showInteractiveIcon)
        
        accessibilityLabel = options.contains(.allowSettingStatus) ? "availability.accessibility_label.change_status".localized : "availability.accessibility_label.status".localized
        accessibilityValue = availability.localizedName
    }
    
    /// Refreshes the appearance of the view, based on the options.
    private func updateAppearance() {
        if options.contains(.useLargeFont) {
            titleFont = FontSpec(.normal, .semibold).font
        } else {
            titleFont = FontSpec(.small, .semibold).font
        }
        
        titleColor = UIColor.dynamic(scheme: .title)
        titleColorSelected = UIColor.from(scheme: .textDimmed, variant: colorSchemeVariant)
    }
    
    // MARK: - Events
    
    @objc private func applicationDidBecomeActive() {
        updateConfiguration()
    }
    
    func userDidChange(_ changeInfo: UserChangeInfo) {
        guard changeInfo.availabilityChanged || changeInfo.nameChanged else { return }
        updateConfiguration()
    }
    
    override func updateAccessibilityLabel() {
        self.accessibilityLabel = "\(user.name ?? "")_is_\(user.availability.localizedName)".localized
    }
    
    func provideHapticFeedback() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
}


extension AvailabilityTitleView {
    
    var actionSheet: UIAlertController {
        get {
            let alert = UIAlertController(title: "availability.message.set_status".localized, message: nil, preferredStyle: .actionSheet)
            for type in Availability.allCases {
                alert.addAction(UIAlertAction(title: type.localizedName, style: .default, handler: { [weak self] (action) in
                    self?.didSelectAvailability(type)
                }))
            }
            alert.popoverPresentationController?.permittedArrowDirections = [ .up ]
            alert.addAction(UIAlertAction(title: "availability.message.cancel".localized, style: .cancel, handler: nil))
            alert.applyTheme()
            return alert
        }
    }
    
    private func didSelectAvailability(_ availability: Availability) {
        ZMUserSession.shared()?.performChanges { [weak self] in
            ZMUser.selfUser().availability = availability
            self?.provideHapticFeedback()
        }
    }
    
}
