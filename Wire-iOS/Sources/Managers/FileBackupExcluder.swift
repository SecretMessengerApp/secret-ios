

import Foundation


private let zmLog = ZMSLog(tag: "UI")

final class FileBackupExcluder: NSObject {

    private static let filesToExclude: [FileInDirectory] = [
        (.libraryDirectory, "Preferences/com.apple.EmojiCache.plist"),
        (.libraryDirectory, ".")
    ]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FileBackupExcluder.applicationWillEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: .none)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(FileBackupExcluder.applicationWillResignActive(_:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: .none)
        
        self.excludeFilesFromBackup()
    }
    
    @objc func applicationWillEnterForeground(_ sender: AnyObject!) {
        self.excludeFilesFromBackup()
    }
    
    @objc func applicationWillResignActive(_ sender: AnyObject!) {
        self.excludeFilesFromBackup()
    }
    
    private func excludeFilesFromBackup() {
        do {
            try type(of: self).filesToExclude.forEach { (directory, path) in
                let url = URL.wr_directory(for: directory).appendingPathComponent(path)
                try url.excludeFromBackupIfExists()
            }
        }
        catch (let error) {
            zmLog.error("Cannot exclude file from the backup: \(self): \(error)")
        }
    }

    func excludeLibraryFolderInSharedContainer(sharedContainerURL : URL ) {
        do {
            let libraryURL = sharedContainerURL.appendingPathComponent("Library")
            try libraryURL.excludeFromBackupIfExists()
        } catch {
            zmLog.error("Cannot exclude file from the backup: \(self): \(error)")
        }
    }
}


fileprivate extension URL {

    func excludeFromBackupIfExists() throws {
        if FileManager.default.fileExists(atPath: path) {
            try wr_excludeFromBackup()
        }
    }

}
