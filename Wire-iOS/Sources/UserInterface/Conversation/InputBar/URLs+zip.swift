
import Foundation
import ZipArchive

extension Array where Element == URL {
    func zipFiles(filename: String = "archive.zip") -> URL? {
        let archiveURL = URL(fileURLWithPath: NSTemporaryDirectory() + filename)

        let paths = map() { $0.path }

        let zipSucceded = SSZipArchive.createZipFile(atPath: archiveURL.path, withFilesAtPaths: paths)

        return zipSucceded ? archiveURL : nil
    }
}
