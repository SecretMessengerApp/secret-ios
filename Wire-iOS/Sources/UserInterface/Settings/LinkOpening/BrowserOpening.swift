

private let log = ZMSLog(tag: "link opening")


enum BrowserOpeningOption: Int, LinkOpeningOption {

    case safari, chrome, firefox, snowhaze, brave

    typealias ApplicationOptionEnum = BrowserOpeningOption
    static var settingKey: SettingKey = .browserOpeningRawValue
    static var defaultPreference: ApplicationOptionEnum = .safari

    static var allOptions: [BrowserOpeningOption] {
        return [.safari, .chrome, .firefox, .snowhaze, .brave]
    }

    var displayString: String {
        switch self {
        case .safari:   return "open_link.browser.option.safari".localized
        case .chrome:   return "open_link.browser.option.chrome".localized
        case .firefox:  return "open_link.browser.option.firefox".localized
        case .snowhaze: return "open_link.browser.option.snowhaze".localized
        case .brave:    return "open_link.browser.option.brave".localized
        }
    }

    var isAvailable: Bool {
        switch self {
        case .safari: return true
        case .chrome: return UIApplication.shared.chromeInstalled
        case .firefox: return UIApplication.shared.firefoxInstalled
        case .snowhaze: return UIApplication.shared.snowhazeInstalled
        case .brave: return UIApplication.shared.braveInstalled
        }
    }
}

extension URL {

    func openAsLink() -> Bool {
        log.debug("Trying to open \"\(self)\" in thrid party browser")
        let saved = BrowserOpeningOption.storedPreference
        log.debug("Saved option to open a regular link: \(saved.displayString)")
        let app = UIApplication.shared

        switch saved {
        case .safari: return false
        case .chrome:
            guard let url = chromeURL, app.canOpenURL(url) else { return false }
            log.debug("Trying to open chrome app using \"\(url)\"")
            app.open(url)
        case .firefox:
            guard let url = firefoxURL, app.canOpenURL(url) else { return false }
            log.debug("Trying to open firefox app using \"\(url)\"")
            app.open(url)
        case .snowhaze:
            guard let url = snowhazeURL, app.canOpenURL(url) else { return false }
            log.debug("Trying to open snowhaze app using \"\(url)\"")
            app.open(url)
        case .brave:
            guard let url = braveURL, app.canOpenURL(url) else { return false }
            log.debug("Trying to open brave app using \"\(url)\"")
            app.open(url)
        }
        
        return true
    }
}


// MARK: - Private


fileprivate extension UIApplication {

    var chromeInstalled: Bool {
        return canHandleScheme("googlechrome://")
    }

    var firefoxInstalled: Bool {
        return canHandleScheme("firefox://")
    }
    
    var snowhazeInstalled: Bool {
        return canHandleScheme("shtps://")
    }
    
    var braveInstalled: Bool {
        return canHandleScheme("brave://")
    }

}


extension URL {

    var chromeURL: URL? {
        if absoluteString.contains("http://") {
            return URL(string: "googlechrome://\(absoluteString.replacingOccurrences(of: "http://", with: ""))")
        }
        if absoluteString.contains("https://") {
            return URL(string: "googlechromes://\(absoluteString.replacingOccurrences(of: "https://", with: ""))")
        }
        return URL(string: "googlechrome://\(absoluteString)")
    }

    var percentEncodingString: String {
        return absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!;
    }

    var firefoxURL: URL? {
        return URL(string: "firefox://open-url?url=\(percentEncodingString)")
    }
    
    var snowhazeURL: URL? {
        if absoluteString.contains("http://") {
            return URL(string: "shtp://\(absoluteString.replacingOccurrences(of: "http://", with: ""))")
        }
        if absoluteString.contains("https://") {
            return URL(string: "shtps://\(absoluteString.replacingOccurrences(of: "https://", with: ""))")
        }
        return URL(string: "shtp://\(absoluteString)")
    }
    
    var braveURL: URL? {
        return URL(string: "brave://open-url?url=\(percentEncodingString)")
    }
}
