

private let log = ZMSLog(tag: "link opening")


enum MapsOpeningOption: Int, LinkOpeningOption {
    case apple, google
    
    typealias ApplicationOptionEnum = MapsOpeningOption
    static var settingKey: SettingKey = .mapsOpeningRawValue
    static var defaultPreference: ApplicationOptionEnum = .apple

    static var allOptions: [MapsOpeningOption] {
        return [.apple, .google]
    }

    var displayString: String {
        switch self {
        case .apple: return "open_link.maps.option.apple".localized
        case .google: return "open_link.maps.option.google".localized
        }
    }

    var isAvailable: Bool {
        switch self {
        case .apple: return true
        case .google: return UIApplication.shared.googleMapsInstalled
        }
    }
}


extension URL {

    public func openAsLocation() -> Bool {
        log.debug("Trying to open \"\(self)\" as location")
        let saved = MapsOpeningOption.storedPreference
        log.debug("Saved option to open a location: \(saved.displayString)")

        switch saved {
        case .apple: return false
        case .google:
            guard UIApplication.shared.canOpenURL(self) else { return false }
            UIApplication.shared.open(self)
            return true
        }
    }
    
}


// MARK: - Private


fileprivate extension UIApplication {

    var googleMapsInstalled: Bool {
        return canHandleScheme("comgooglemaps://")
    }

}
