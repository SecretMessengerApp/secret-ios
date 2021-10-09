

import Foundation

private let zmLog = ZMSLog(tag: "FileManager")

extension URL {
    static func directoryURL(_ pathComponent: String) -> URL? {
        let url = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return url?.appendingPathComponent(pathComponent)
    }
}
