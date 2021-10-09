

private let log = ZMSLog(tag: "link opening")


enum TweetOpeningOption: Int, LinkOpeningOption {
    case none, tweetbot, twitterrific

    typealias ApplicationOptionEnum = TweetOpeningOption
    static var settingKey: SettingKey = .twitterOpeningRawValue
    static var defaultPreference: ApplicationOptionEnum = .none

    var displayString: String {
        switch self {
        case .none: return "open_link.twitter.option.default".localized
        case .tweetbot: return "open_link.twitter.option.tweetbot".localized
        case .twitterrific: return "open_link.twitter.option.twitterrific".localized
        }
    }

    static var allOptions: [TweetOpeningOption] {
        return [.none, .tweetbot, .twitterrific]
    }

    var isAvailable: Bool {
        switch self {
        case .none: return true
        case .tweetbot: return UIApplication.shared.tweetbotInstalled
        case .twitterrific: return UIApplication.shared.twitterrificInstalled
        }
    }
}


extension URL {

    func openAsTweet() -> Bool {
        log.debug("Trying to open \"\(self)\" as tweet, isTweet: \(isTweet)")
        guard isTweet else { return false }
        let saved = TweetOpeningOption.storedPreference
        log.debug("Saved option to open a tweet: \(saved.displayString)")
        let app = UIApplication.shared
        
        switch saved {
        case .none: return false
        case .tweetbot:
            guard let url = tweetbotURL, app.canOpenURL(url) else { return false }
            log.debug("Trying to open tweetbot app using \"\(url)\"")
            app.open(url)
        case .twitterrific:
            guard let url = twitterrificURL, app.canOpenURL(url) else { return false }
            log.debug("Trying to open twitterific app using \"\(url)\"")
            app.open(url)
        }
        
        return true
    }

}


// MARK: - Private


fileprivate extension UIApplication {

    var tweetbotInstalled: Bool {
        return canHandleScheme("tweetbot://")
    }

    var twitterrificInstalled: Bool {
        return canHandleScheme("twitterrific://")
    }

}


extension URL {

    var isTweet: Bool {
        return absoluteString.contains("twitter.com") && absoluteString.contains("status")
    }

}


fileprivate extension URL {

    var tweetbotURL: URL? {
        guard isTweet else { return nil }

        let components = [
            "https://twitter.com/",
            "http://twitter.com/",
            "http://mobile.twitter.com/",
            "https://mobile.twitter.com/"
        ]

        let tweetbot = components.reduce(absoluteString) { result, current in
            return result.replacingWithTweetbotURLScheme(current)
        }

        return URL(string: tweetbot)
    }

    var twitterrificURL: URL? {
        return tweetID.flatMap { URL(string: "twitterrific://current/tweet?id=\($0)") }
    }

    private var tweetID: String? {
        guard let statusRange = absoluteString.range(of: "status/") else { return nil }
        return String(absoluteString[statusRange.upperBound...])
    }

}


private extension String {

    func replacingWithTweetbotURLScheme(_ string: String) -> String {
        return replacingOccurrences(of: string, with: "tweetbot://")
    }
    
}
