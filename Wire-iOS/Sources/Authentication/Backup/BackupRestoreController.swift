
import Foundation
import WireDataModel

protocol BackupRestoreControllerDelegate: class {
    func backupResoreControllerDidFinishRestoring(_ controller: BackupRestoreController)
}

/**
 * An object that coordinates restoring a backup.
 */

class BackupRestoreController: NSObject {
    static let WireBackupUTI = "com.secret.ios-backup"

    let target: UIViewController
    weak var delegate: BackupRestoreControllerDelegate?

    // MARK: - Initialization

    init(target: UIViewController) {
        self.target = target
        super.init()
    }

    // MARK: - Flow

    func startBackupFlow() {
        let controller = UIAlertController.historyImportWarning { [showFilePicker] in
            showFilePicker()
        }

        target.present(controller, animated: true)
    }

    fileprivate func showFilePicker() {
        // Test code to verify restore
        #if arch(i386) || arch(x86_64)
        let testFilePath = "/var/tmp/backup.ios_wbu"
        if FileManager.default.fileExists(atPath: testFilePath) {
            self.restore(with: URL(fileURLWithPath: testFilePath))
            return
        }
        #endif

        let picker = UIDocumentPickerViewController(documentTypes: [BackupRestoreController.WireBackupUTI], in: .`import`)
        picker.delegate = self
        target.present(picker, animated: true)
    }

    fileprivate func restore(with url: URL) {
        requestPassword { [performRestore] password in
            performRestore(password, url)
        }
    }

    fileprivate func performRestore(using password: String, from url: URL) {
        guard let sessionManager = SessionManager.shared else { return }
        target.showLoadingView = true

        sessionManager.restoreFromBackup(at: url, password: password) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .failure(SessionManager.BackupError.decryptionError):
                self.target.showLoadingView = false
                self.showWrongPasswordAlert { _ in
                    self.restore(with: url)
                }

            case .failure(let error):
                BackupEvent.importFailed.track()
                self.showRestoreError(error)
                self.target.showLoadingView = false

            case .success:
                BackupEvent.importSucceeded.track()
                self.delegate?.backupResoreControllerDidFinishRestoring(self)
            }
        }
    }

    // MARK: - Alerts

    fileprivate func requestPassword(completion: @escaping (String) -> Void) {
        let controller = UIAlertController.requestRestorePassword { password in
            password.apply(completion)
        }

        target.present(controller, animated: true, completion: nil)
    }

    fileprivate func showWrongPasswordAlert(completion: @escaping (UIAlertAction) -> Void) {
        let controller = UIAlertController.importWrongPasswordError(completion: completion)
        target.present(controller, animated: true, completion: nil)
    }

    fileprivate func showRestoreError(_ error: Error) {
        let controller = UIAlertController.restoreBackupFailed(with: error) { [unowned self] action in
            switch action {
            case .tryAgain: self.showFilePicker()
            case .cancel: self.delegate?.backupResoreControllerDidFinishRestoring(self)
            }
        }

        target.present(controller, animated: true)
    }
}

extension BackupRestoreController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        self.restore(with: url)
    }
}
