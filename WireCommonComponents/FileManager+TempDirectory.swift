
import Foundation

extension FileManager {
    static public func createTmpDirectory(fileName: String? = nil) throws -> URL {
        let fileManager = FileManager.default
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(fileName ?? UUID().uuidString) // temp subdir
        if !fileManager.fileExists(atPath: tmp.absoluteString) {
            try fileManager.createDirectory(at: tmp, withIntermediateDirectories: true)
        }

        return tmp
    }

    public func removeTmpIfNeededAndCopy(fileURL: URL, tmpURL: URL) throws {
        if fileExists(atPath: tmpURL.path) {
                try FileManager.default.removeItem(at: tmpURL)
        }

        try copyItem(at: fileURL, to: tmpURL)

    }
}
