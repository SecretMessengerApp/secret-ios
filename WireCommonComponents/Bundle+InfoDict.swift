

import Foundation
import UIKit

public extension Bundle {
    func infoForKey(_ key: String) -> String? {
        return infoDictionary?[key] as? String
    }
    
    static var appMainBundle: Bundle {
        let mainBundle: Bundle
        if UIApplication.runningInExtension {
            let extensionBundleURL = Bundle.main.bundleURL
            let mainAppBundleURL = extensionBundleURL.deletingLastPathComponent().deletingLastPathComponent()
            guard let bundle = Bundle(url: mainAppBundleURL) else { fatalError("Failed to find main app bundle") }
            mainBundle = bundle
        } else {
            mainBundle = .main
        }
        return mainBundle
    }
}
