
import Foundation

extension URL {
    var urlWithoutScheme: String {
        return stringWithoutPrefix("\(scheme ?? "")://")
    }

    var urlWithoutSchemeAndHost: String {
        return stringWithoutPrefix("\(scheme ?? "")://\(host ?? "")")
    }

    private func stringWithoutPrefix(_ prefix: String) -> String {
        guard absoluteString.hasPrefix(prefix) else { return absoluteString }
        return String(absoluteString.dropFirst(prefix.count))
    }
}

extension String {

    // MARK: - URL Formatting

    var removingPrefixWWW: String {
        let prefix = "www."

        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    var removingTrailingForwardSlash: String {
        let suffix = "/"

        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
