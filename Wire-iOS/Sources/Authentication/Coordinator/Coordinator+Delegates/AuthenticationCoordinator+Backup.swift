
import Foundation

extension AuthenticationCoordinator: BackupRestoreControllerDelegate {

    func backupResoreControllerDidFinishRestoring(_ controller: BackupRestoreController) {
        self.executeActions([.configureNotifications, .completeBackupStep])
    }

}
