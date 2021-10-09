
import Foundation

extension AppDelegate {
    @objc
    func open(url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        guard let urlHandler = sessionManager?.urlHandler else { return false }
        return urlHandler.openURL(url, options: options)
    }
}

