
import Foundation

extension SelfProfileViewController {

    @discardableResult func presentUserSettingChangeControllerIfNeeded() -> Bool {
        if ZMUser.selfUser()?.readReceiptsEnabledChangedRemotely ?? false {
            let currentValue = ZMUser.selfUser()!.readReceiptsEnabled
            self.presentReadReceiptsChangedAlert(with: currentValue)
            
            return true
        }
        else {
            return false
        }
    }
    
    fileprivate func presentReadReceiptsChangedAlert(with newValue: Bool) {
        let title = newValue ? "self.read_receipts_enabled.title".localized : "self.read_receipts_disabled.title".localized
        let description = "self.read_receipts_description.title".localized
        
        let settingsChangedAlert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "general.ok".localized, style: .default) { [weak settingsChangedAlert] _ in
            ZMUserSession.shared()?.performChanges {
                ZMUser.selfUser()?.readReceiptsEnabledChangedRemotely = false
            }
            settingsChangedAlert?.dismiss(animated: true)
        }

        settingsChangedAlert.addAction(okAction)
        
        self.present(settingsChangedAlert, animated: true)
    }
    
}
