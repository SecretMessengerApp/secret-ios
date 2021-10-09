
import Foundation

extension SelfProfileViewController {
    

    func presentNewLoginAlertControllerIfNeeded() -> Bool {
        let clientsRequiringUserAttention = ZMUser.selfUser().clientsRequiringUserAttention
        
        if clientsRequiringUserAttention.count > 0 {
//            self.presentNewLoginAlertController(clientsRequiringUserAttention)
            return true
        }
        else {
            return false
        }
    }
    
    fileprivate func presentNewLoginAlertController(_ clients: Set<UserClient>) {
        let newLoginAlertController = UIAlertController(forNewSelfClients: clients)
        
        let actionManageDevices = UIAlertAction(title: "self.new_device_alert.manage_devices".localized, style:.default) { _ in
            self.openControllerForCellWithIdentifier(SettingsCellDescriptorFactory.settingsDevicesCellIdentifier)
        }
        
        newLoginAlertController.addAction(actionManageDevices)
        
        let actionTrustDevices = UIAlertAction(title:"self.new_device_alert.trust_devices".localized, style:.default) { [weak self] _ in
            self?.presentUserSettingChangeControllerIfNeeded()
        }
        
        newLoginAlertController.addAction(actionTrustDevices)
        
        self.present(newLoginAlertController, animated: true, completion: .none)
        
        ZMUserSession.shared()?.enqueueChanges {
            clients.forEach {
                $0.needsToNotifyUser = false
            }
        }
    }
    
    @discardableResult func openControllerForCellWithIdentifier(_ identifier: String) -> UIViewController? {
        var resultViewController: UIViewController? = .none
        // Let's assume for the moment that menu is only 2 levels deep
        rootGroup?.allCellDescriptors().forEach({ (topCellDescriptor: SettingsCellDescriptorType) -> () in
            
            if let cellIdentifier = topCellDescriptor.identifier,
                let cellGroupDescriptor = topCellDescriptor as? SettingsControllerGeneratorType,
                let viewController = cellGroupDescriptor.generateViewController(),
                cellIdentifier == identifier
            {
                self.navigationController?.pushViewController(viewController, animated: false)
                resultViewController = viewController
            }
            
            if let topCellGroupDescriptor = topCellDescriptor as? SettingsInternalGroupCellDescriptorType & SettingsControllerGeneratorType {
                topCellGroupDescriptor.allCellDescriptors().forEach({ (cellDescriptor: SettingsCellDescriptorType) -> () in
                    if let cellIdentifier = cellDescriptor.identifier,
                        let cellGroupDescriptor = cellDescriptor as? SettingsControllerGeneratorType,
                        let topViewController = topCellGroupDescriptor.generateViewController(),
                        let viewController = cellGroupDescriptor.generateViewController(),
                        cellIdentifier == identifier
                    {
                        self.wr_splitViewController?.pushToRightPossible(topViewController, from: self, animated: false)
                        self.wr_splitViewController?.pushToRightPossible(viewController, from: self, animated: false)
//                        self.navigationController?.pushViewController(topViewController, animated: false)
//                        self.wr_splitViewController?.pushToRightPossible(viewController, from: self)
//                        self.navigationController?.pushViewController(viewController, animated: false)
                        resultViewController = viewController
                    }
                })
            }
            
        })
        
        return resultViewController
    }
    
}
