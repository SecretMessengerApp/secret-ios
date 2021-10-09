
import Foundation
import ZipArchive

class DocumentDelegate : NSObject, UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.topmostViewController(onlyFullScreen: false)!
    }
    
}


class SettingsShareDatabaseCellDescriptor : SettingsButtonCellDescriptor {
    
    let documentDelegate : DocumentDelegate
    
    init() {
        let documentDelegate = DocumentDelegate()
        self.documentDelegate = documentDelegate
        
        super.init(title: "Share Database", isDestructive: false) { _ in
            let fileURL = ZMUserSession.shared()!.managedObjectContext.zm_storeURL!
            let archiveURL = fileURL.appendingPathExtension("zip")
            
            SSZipArchive.createZipFile(atPath: archiveURL.path, withFilesAtPaths: [fileURL.path])
            
            let shareDatabaseDocumentController = UIDocumentInteractionController(url: archiveURL)
            shareDatabaseDocumentController.delegate = documentDelegate
            shareDatabaseDocumentController.presentPreview(animated: true)
        }
    
    }
    
}

class SettingsShareCryptoboxCellDescriptor : SettingsButtonCellDescriptor {
    
    let documentDelegate : DocumentDelegate
    
    init() {
        let documentDelegate = DocumentDelegate()
        self.documentDelegate = documentDelegate
        
        super.init(title: "Share Cryptobox", isDestructive: false) { _ in
            let fileURL = ZMUserSession.shared()!.managedObjectContext.zm_storeURL!.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("otr")
            let archiveURL = fileURL.appendingPathExtension("zip")
            
            SSZipArchive.createZipFile(atPath: archiveURL.path, withContentsOfDirectory: fileURL.path)
            
            let shareDatabaseDocumentController = UIDocumentInteractionController(url: archiveURL)
            shareDatabaseDocumentController.delegate = documentDelegate
            shareDatabaseDocumentController.presentPreview(animated: true)
        }
        
    }
    
}
