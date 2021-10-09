

import MobileCoreServices
import WireUtilities


extension NSItemProvider {

    /// Extracts the URL from the item provider
    func fetchURL(completion: @escaping (URL?)->()) {
        loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil, completionHandler: { (url, error) in
            error?.log(message: "Unable to fetch URL for type URL")
            completion(url as? URL)
        })
    }
}
