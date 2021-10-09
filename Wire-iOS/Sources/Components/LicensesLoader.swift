
import Foundation

/**
 * Loads the list of licenses embedded inside the app.
 *
 * This object is not thread safe and should only be used from the main thread.
 */

@objc class LicensesLoader: NSObject {

    /// The shared loader.
    static let shared = LicensesLoader()

    private let sourceName = "Licenses.generated"
    private let sourceExtension = "plist"

    private(set) var cache: [SettingsLicenseItem]? = nil
    private var memoryWarningToken: Any?

    // MARK: - Initialization

    init(memoryManager: Any? = nil) {
        super.init()
        memoryWarningToken = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: memoryManager, queue: .main) { [weak self] _ in
            self?.cache = nil
        }
    }

    deinit {
        memoryWarningToken.apply(NotificationCenter.default.removeObserver)
    }

    // MARK: - Reading the list of Licences

    /// Returns the list of 3rd party licences used by the app.
    func loadLicenses() -> [SettingsLicenseItem]? {
        if let cachedItems = cache {
            return cachedItems
        }

        guard
            let plistURL = Bundle.main.url(forResource: sourceName, withExtension: sourceExtension),
            let plistContents = try? Data(contentsOf: plistURL),
            let decodedPlist = try? PropertyListDecoder().decode([SettingsLicenseItem].self, from: plistContents)
        else {
            return nil
        }

        self.cache = decodedPlist
        return decodedPlist
    }

    // MARK: - Testing

    var cacheEmpty: Bool {
        return cache == nil
    }

}
