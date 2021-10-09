
import Foundation

private let zmLog = ZMSLog(tag: "URL")

@objc enum TeamSource: Int {
    case onboarding, settings
    
    var parameterValue: String {
        switch self {
        case .onboarding: return "client_landing"
        case .settings: return "client_settings"
        }
    }
}

struct WireUrl: Codable {
    let wireAppOnItunes: URL
    let googleAuthAppOnItunes: URL
    let support: URL
    let randomProfilePictureSource: URL

    static var shared: WireUrl! = {
        guard let filePath = Bundle.main.url(forResource: "url", withExtension: "json") else {
            zmLog.error("Failed to get URL from bundle")
            return nil
        }

        return WireUrl(filePath: filePath)
    }()

    private init?(filePath: URL) {

        let data: Data
        do {
            data = try Data(contentsOf: filePath)
        } catch {
            zmLog.error("Failed to load URL at path: \(filePath), error: \(error)")
            return nil
        }

        let decoder = JSONDecoder()

        do {
            self = try decoder.decode(WireUrl.self, from: data)
        } catch {
            zmLog.error("Failed to parse JSON at path: \(filePath), error: \(error)")
            return nil
        }
    }
}

extension URL {

    var appendingLocaleParameter: URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        let localeQueryItem = URLQueryItem(name: "hl", value: Locale.current.identifier)

        var queryItems = components.queryItems ?? []
        queryItems.append(localeQueryItem)
        components.queryItems = queryItems

        return components.url ?? self
    }

    static func manageTeam(source: TeamSource) -> URL {
        let baseURL = BackendEnvironment.shared.teamsURL

        let queryItems = [URLQueryItem(name: "utm_source", value: source.parameterValue),
                          URLQueryItem(name: "utm_term", value: "ios")]

        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)

        components?.queryItems = queryItems

        return components!.url!.appendingLocaleParameter
    }
}

// MARK: - Standard URLS

extension BackendEnvironment {
    fileprivate static func websiteLink(path: String) -> URL {
        return shared.websiteURL.appendingPathComponent(path)
    }
    
    fileprivate static func accountsLink(path: String) -> URL {
        return shared.accountsURL.appendingPathComponent(path)
    }
    
    fileprivate static func teamsLink(path: String) -> URL {
        return shared.teamsURL.appendingPathComponent(path)
    }

}


extension URL {

    static var wr_wireAppOnItunes: URL {
        return WireUrl.shared.wireAppOnItunes
    }
    
    static var wr_googleAuthAppOnItunes: URL {
        return WireUrl.shared.googleAuthAppOnItunes
    }
    
    static var wr_randomProfilePictureSource: URL {
        return WireUrl.shared.randomProfilePictureSource
    }

    static var wr_emailAlreadyInUseLearnMore: URL {
        return wr_support.appendingPathComponent("hc/en-us/articles/115004082129-My-email-address-is-already-in-use-and-I-cannot-create-an-account-What-can-I-do-")
    }
    
    static var wr_support: URL {
        return WireUrl.shared.support
    }

    static var wr_usernameLearnMore: URL {
        return BackendEnvironment.websiteLink(path: "support/username")
    }

    static var wr_fingerprintLearnMore: URL {
        return BackendEnvironment.websiteLink(path: "privacy/why")
    }

    static var wr_fingerprintHowToVerify: URL {
        return BackendEnvironment.websiteLink(path: "privacy/how")
    }

    static var wr_privacyPolicy: URL {
//        return BackendEnvironment.websiteLink(path: "legal/privacy/embed")
        return URL(string: "https://service.isecret.im/info/private")!
    }

    static var wr_licenseInformation: URL {
        return BackendEnvironment.websiteLink(path: "legal/licenses/embed")
    }

    static var wr_website: URL {
        return BackendEnvironment.shared.websiteURL
    }

    static var wr_passwordReset: URL {
//        return BackendEnvironment.accountsLink(path: "forgot")
        return URL(string: "http://service.isecret.im/index.php/Secret/forgot")!
    }

    static var wr_askSupport: URL {
        return wr_support.appendingPathComponent("hc/requests/new")
    }

    static var wr_reportAbuse: URL {
        return BackendEnvironment.websiteLink(path: "support/misuse")
    }

    static var wr_cannotDecryptHelp: URL {
        return BackendEnvironment.websiteLink(path: "privacy/error-1")
    }

    static var wr_cannotDecryptNewRemoteIDHelp: URL {
        return BackendEnvironment.websiteLink(path: "privacy/error-2")
    }

    static var wr_createTeam: URL {
        return BackendEnvironment.websiteLink(path: "create-team?pk_campaign=client&pk_kwd=ios")
    }

    static var wr_createTeamFeatures: URL {
        return BackendEnvironment.websiteLink(path: "teams/learnmore")
    }

    static var wr_manageTeam: URL {
        return BackendEnvironment.teamsLink(path: "login?pk_campaign=client&pk_kwd=ios")
    }

    static var wr_emailInUseLearnMore: URL {
        return BackendEnvironment.websiteLink(path: "support/email-in-use")
    }


    static func wr_termsOfServicesURL(forTeamAccount isTeamAccount: Bool) -> URL {
        if isTeamAccount {
//            return BackendEnvironment.websiteLink(path: "legal/terms/teams")
            return URL(string: "https://www.isecret.im/agreement-en.html")!
        } else {
//            return BackendEnvironment.websiteLink(path: "legal/terms/personal")
            return URL(string: "https://www.isecret.im/agreement-en.html")!
        }
    }

}

extension NSURL {

    @objc static var wr_fingerprintLearnMoreURL: NSURL {
        return URL.wr_fingerprintLearnMore as NSURL
    }

}
