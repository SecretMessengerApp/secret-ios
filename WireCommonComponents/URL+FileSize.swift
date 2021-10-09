
import Foundation

public extension URL {

    /// return nil if can not obtain the file size from URL
    var fileSize: UInt64? {
        guard let attributes: [FileAttributeKey: Any] = try? FileManager.default.attributesOfItem(atPath: path) else { return nil }

        return attributes[FileAttributeKey.size] as? UInt64
    }
}

extension UInt64 {
    private static let MaxFileSize: UInt64 = 104857600 // 25 megabytes (25 * 1024 * 1024)
    private static let MaxTeamFileSize: UInt64 = 104857600 // 100 megabytes (100 * 1024 * 1024)

    public static var uploadFileSizeLimit: UInt64 {
        MaxFileSize
    }
}
