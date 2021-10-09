

import Foundation
import WireCommonComponents
import WireUtilities

private let zmLog = ZMSLog(tag: "UI")

class ExtensionBackupExcluder {

    private static let filesToExclude: [FileInDirectory] = [
        (.libraryDirectory, "Cookies/Cookies.binarycookies"),
        (.libraryDirectory, ".")
    ]

    static func exclude() {
        do {
            try filesToExclude.forEach { (directory, path) in
                let url = URL.wr_directory(for: directory).appendingPathComponent(path)
                if FileManager.default.fileExists(atPath: url.path) {
                    try url.wr_excludeFromBackup()
                }
            }
        } catch {
            zmLog.error("Cannot exclude file from the backup: \(self): \(error)")
        }
    }

}
