
import Foundation

public extension String {

    var containsURL: Bool {
        return URLMatchesInString.count > 0
    }

    var URLsInString: [URL?] {
        return URLMatchesInString.map(\.url)
    }

    private var URLMatchesInString: [NSTextCheckingResult] {
        do {
            let urlDetector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
            let matches = urlDetector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            return matches
        } catch _ as NSError {
            return []
        }
    }
}
