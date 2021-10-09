
import Foundation

extension Notification.Name {
    static let colorSchemeControllerDidApplyColorSchemeChange = Notification.Name("ColorSchemeControllerDidApplyColorSchemeChange")
}

extension NSNotification {
    static let colorSchemeControllerDidApplyColorSchemeChange = Notification.Name.colorSchemeControllerDidApplyColorSchemeChange
}

class ColorSchemeController: NSObject {

    var userObserverToken: Any?

    override init() {
        super.init()

        if let session = ZMUserSession.shared() {
            userObserverToken = UserChangeInfo.add(observer: self, for: SelfUser.current, userSession: session)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(settingsColorSchemeDidChange), name: .SettingsColorSchemeChanged, object: nil)

    }

    func notifyColorSchemeChange() {
        NotificationCenter.default.post(name: .colorSchemeControllerDidApplyColorSchemeChange, object: self)
    }

    @objc
    private func settingsColorSchemeDidChange() {
        ColorScheme.default.variant = Settings.shared.colorSchemeVariant

        NSAttributedString.invalidateMarkdownStyle()

        notifyColorSchemeChange()
    }
}

extension ColorSchemeController: ZMUserObserver {
    public func userDidChange(_ note: UserChangeInfo) {
        guard note.accentColorValueChanged else { return }

        let colorScheme = ColorScheme.default

        if !colorScheme.isCurrentAccentColor(UIColor.accent()) {
            notifyColorSchemeChange()
        }
    }
}
