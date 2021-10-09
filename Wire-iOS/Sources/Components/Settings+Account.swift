
import Foundation

extension Account {
    func userDefaultsKey() -> String {
        return "account_\(self.userIdentifier.transportString())"
    }
}

extension Settings {
    private func payload(for account: Account) -> [String: Any] {
        return defaults.value(forKey: account.userDefaultsKey()) as? [String: Any] ?? [:]
    }

    /// Returns the value associated with the given account for the given key
    ///
    /// - Parameters:
    ///   - key: the SettingKey enum
    ///   - account: account to get value
    /// - Returns: the setting of the account
    func value<T>(for settingKey: SettingKey, in account: Account) -> T? {
        let key = settingKey.rawValue

        // Attempt to migrate the shared value
        if let rootValue = defaults.value(forKey: key) {
            setValue(rootValue, settingKey: settingKey, in: account)
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }

        let accountPayload = payload(for: account)
        return accountPayload[key] as? T
    }
    
    // TODO: ToSwift delete this func
    @available(*, deprecated, message: "Use the `value<T>(for settingKey: SettingKey, in account: Account)-> T?` instead")
    func value<T>(for key: String, in account: Account) -> T? {
        if let rootValue = defaults.value(forKey: key) {
            setValue(rootValue, for: key, in: account)
            defaults.removeObject(forKey: key)
            defaults.synchronize()
        }
        let accountPayload = payload(for: account)
        return accountPayload[key] as? T
    }

    /// Sets the value associated with the given account for the given key.
    ///
    /// - Parameters:
    ///   - value: value to set
    ///   - settingKey: the SettingKey enum
    ///   - account: account to set value
    func setValue<T>(_ value: T?, settingKey: SettingKey, in account: Account) {
        let key = settingKey.rawValue
        var accountPayload = payload(for: account)
        accountPayload[key] = value
        defaults.setValue(accountPayload, forKey: account.userDefaultsKey())
    }
    
    // TODO: ToSwift delete this func
    @available(*, deprecated, message: "Use the `setValue<T>(_ value: T?, settingKey: SettingKey, in account: Account)` instead")
    func setValue<T>(_ value: T?, for key: String, in account: Account) {
        var accountPayload = payload(for: account)
        accountPayload[key] = value
        defaults.setValue(accountPayload, forKey: account.userDefaultsKey())
    }
    

    func lastViewedConversation(for account: Account) -> ZMConversation? {
        guard let conversationID: String = self.value(for: .lastViewedConversation, in: account) else {
            return nil
        }

        let conversationURI = URL(string: conversationID)
        let session = ZMUserSession.shared()
        let objectID = ZMManagedObject.objectID(forURIRepresentation: conversationURI, inUserSession: session)
        return ZMConversation.existingObject(with: objectID, inUserSession: session)
    }

    func setLastViewed(conversation: ZMConversation, for account: Account) {
        let conversationURI = conversation.objectID.uriRepresentation()
        setValue(conversationURI.absoluteString, settingKey: .lastViewedConversation, in: account)
        defaults.synchronize()
    }

    func notifyDisableSendButtonChanged() {
        NotificationCenter.default.post(name: .disableSendButtonChanged, object: self, userInfo: nil)
    }
}

extension Notification.Name {
    static let disableSendButtonChanged = Notification.Name("DisableSendButtonChanged")
}


// MARK: - Shortcut Conversation
extension Settings {
    
    func shortcutConversations(for account: Account) -> (ids: [String], unduplicatedPushedIDs: [String]) {
        var result = [String]()
        if let ids: [String] = self.value(for: .shortcutConversations, in: account) {
            result.append(contentsOf: ids)
        }
        
        var unduplicatedPushedIDs = [String]()
        pushedConversationIDs(for: account).reversed().forEach { item in
            if !result.contains(item) {
                result.insert(item, at: 0)
                unduplicatedPushedIDs.append(item)
            }
        }
        
        return (result, unduplicatedPushedIDs)
    }
    

    @objc func pushedConversationIDs(for account: Account) -> [String] {
        let userID = account.userIdentifier.transportString()
        var arr = [String]()
        if let items = UserDefaults.standard.array(forKey: "5th-\(userID)") {
            arr = items.compactMap { item in
                if let dict = item as? [AnyHashable : String] {
                    return dict["conv"]
                } else {
                    return nil
                }
            }
        }
        
        return arr
    }
    
    @objc func removePushedConversationID(convID: String, userID: String) {
        let key = "5th-\(userID)"
        if let items = UserDefaults.standard.array(forKey: key) {
            let arr: [Any] = items.compactMap { item in
                if let dict = item as? [AnyHashable : String], dict["conv"] == convID {
                    return nil
                } else {
                    return item
                }
            }
            UserDefaults.standard.set(arr, forKey: key)
        }
    }
    
    @discardableResult
    @objc func setShortcutConversation(_ conversation: ZMConversation, for account: Account) -> Bool {
        guard let id = conversation.remoteIdentifier?.transportString() else {return false}
        var success = false
        if var ids: [String] = self.value(for: .shortcutConversations, in: account) {
            if ids.count >= 24 {
                success = false
            } else if ids.contains(id) {
                success = true
            } else {
                ids.append(id)
                setValue(ids, settingKey: .shortcutConversations, in: account)
                success = true
            }
        } else {
            self.setValue([id], settingKey: .shortcutConversations, in: account)
            success = true
        }
        self.showHUD(success: success)
        return success
    }
    
    @discardableResult
    @objc func removeShortcurConversation(_ conversation: ZMConversation, for account: Account) -> Bool {
        guard let id = conversation.remoteIdentifier?.transportString() else {return false}
        if var ids: [String] = self.value(for: .shortcutConversations, in: account), let index = ids.firstIndex(of: id) {
            ids.remove(at: index)
            self.setValue(ids, settingKey: .shortcutConversations, in: account)
            return true
        }
        
        removePushedConversationID(convID: id, userID: account.userIdentifier.transportString())
        return false
    }
    
    @objc func markClicked(_ conversation: ZMConversation) {
        guard let id = conversation.remoteIdentifier?.transportString() else { return }
        guard let account = SessionManager.shared?.accountManager.selectedAccount else { return }
        
        let key = "5th-redpoint-\(id)-\(account.userIdentifier.transportString())"
        UserDefaults.shared().set(true, forKey: key)

    }
    
    @objc func hasClicked(_ conversation: ZMConversation) -> Bool {

        guard let id = conversation.remoteIdentifier?.transportString() else { return true }
        guard let account = SessionManager.shared?.accountManager.selectedAccount else { return true }
        
        let key = "5th-redpoint-\(id)-\(account.userIdentifier.transportString())"
        return UserDefaults.shared().bool(forKey: key)
    }
    
    @objc func containsShortcutConversation(_ conversation: ZMConversation) -> Bool {
        guard let id = conversation.remoteIdentifier?.transportString() else {return false}
        guard let currentAccount = SessionManager.shared?.accountManager.selectedAccount else { return false}
        if let ids: [String] = self.value(for: .shortcutConversations, in: currentAccount), ids.firstIndex(of: id) != nil {
            return true
        }
        return false
    }
    
    @objc func hasShortcutConversation() -> Bool {
        guard let currentAccount = SessionManager.shared?.accountManager.selectedAccount else { return false}
        if let ids: [String] = self.value(for: .shortcutConversations, in: currentAccount) {
            let conversationids = ids.filter { (id) -> Bool in
                guard let uuid = UUID(uuidString: id),
                      ZMConversation(remoteID: uuid) != nil else {
                    return false
                }
                return true
            }
            
            return conversationids.count > 0
        }
        

        return pushedConversationIDs(for: currentAccount).count > 0
    }
    
    @objc func showHUD(success: Bool) {
        delay(0.5) {
            if success {
                HUD.success("hud.success.added".localized)
            } else {
                HUD.success("hud.success.addfailed".localized)
            }
        }
    }
    
}
