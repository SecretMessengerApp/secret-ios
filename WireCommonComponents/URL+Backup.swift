

import Foundation

public typealias FileInDirectory = (FileManager.SearchPathDirectory, String)

public extension URL {
    ///TODO: retire, use Wire utility's excludeFromBackup
    func wr_excludeFromBackup() throws {
        var mutableCopy = self
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try mutableCopy.setResourceValues(resourceValues)
    }

    ///TODO: mv to utility
    static func wr_directory(for searchPathDirectory: FileManager.SearchPathDirectory) -> URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(searchPathDirectory, .userDomainMask, true).first!)
    }

}
