

import Foundation

extension MainTabBarController {
    
    func presentNewLoginAlertControllerIfNeeded() {
        if ZMUser.selfUser() != nil {
            let clientsRequiringUserAttention = ZMUser.selfUser().clientsRequiringUserAttention
            
            if clientsRequiringUserAttention.count > 0 {
                self.presentNewLoginAlertController(clientsRequiringUserAttention)
            }
        }
    }
    
    fileprivate func presentNewLoginAlertController(_ clients: Set<UserClient>) {
        let newLoginAlertController = UIAlertController(forNewSelfClients: clients)
        
        let selectSelfProfileViewController = { [weak self] in
            guard let `self` = self else {return}
            if let index = self.viewControllers?.firstIndex(of: self.selfProfileNavigationController) {
                self.selectedIndex = index
            }
        }
        
        let actionManageDevices = UIAlertAction(title: "self.new_device_alert.manage_devices".localized, style: .default) { [weak self] _ in
            selectSelfProfileViewController(); self?.selfProfileViewController.openControllerForCellWithIdentifier(SettingsCellDescriptorFactory.settingsDevicesCellIdentifier)
        }
        
        newLoginAlertController.addAction(actionManageDevices)
        
        let actionTrustDevices = UIAlertAction(title: "self.new_device_alert.trust_devices".localized, style: .default) { [weak self] _ in
            selectSelfProfileViewController()
            self?.selfProfileViewController?.presentUserSettingChangeControllerIfNeeded()
        }
        
        newLoginAlertController.addAction(actionTrustDevices)
        
        self.present(newLoginAlertController, animated: true, completion: .none)
        
        ZMUserSession.shared()?.enqueueChanges {
            clients.forEach {
                $0.needsToNotifyUser = false
            }
        }
    }
}
