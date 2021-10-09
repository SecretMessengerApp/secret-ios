

import Foundation
import SafariServices

private let log = ZMSLog(tag: "link opening")


public extension NSURL {

    @discardableResult @objc func open() -> Bool {
        return (self as URL).open()
    }

}

public extension URL {

    @discardableResult func open() -> Bool {
        let opened = openAsTweet() || openAsLink()
        if opened {
            return true
        }
        else {
            log.debug("Did not open \"\(self)\" in a twitter application or third party browser.")
            guard UIApplication.shared.canOpenURL(self) else { return false }
            UIApplication.shared.open(self)
            return true
        }
    }

    func openInApp(above viewController: UIViewController) {
        let browser = BrowserViewController(url: self)
        browser.modalPresentationCapturesStatusBarAppearance = true
        viewController.present(browser, animated: true, completion: nil)
    }

}

extension NSURL {

    @objc func openInApp(aboveViewController viewController: UIViewController) {
        (self as URL).openInApp(above: viewController)
    }

}

protocol LinkOpeningOption {
    associatedtype ApplicationOptionEnum: RawRepresentable where ApplicationOptionEnum.RawValue == Int

    static var allOptions: [Self] { get }
    var isAvailable: Bool { get }
    var displayString: String { get }
    static var availableOptions: [Self] { get }

    static var storedPreference: ApplicationOptionEnum { get }
    static var settingKey: SettingKey { get }
    static var defaultPreference: ApplicationOptionEnum { get }
}


extension LinkOpeningOption {

    static var storedPreference: ApplicationOptionEnum {
        if let openingRawValue: ApplicationOptionEnum.RawValue = Settings.shared[settingKey],
            let openingOption: ApplicationOptionEnum = ApplicationOptionEnum.init(rawValue: openingRawValue) {
            return openingOption
        }

        return defaultPreference
    }

    static var availableOptions: [Self] {
        return allOptions.filter { $0.isAvailable }
    }

    static var optionsAvailable: Bool {
        return availableOptions.count > 1
    }

}


extension UIApplication {

    func canHandleScheme(_ scheme: String) -> Bool {
        return URL(string: scheme).map(canOpenURL) ?? false
    }

}
