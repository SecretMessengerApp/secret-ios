
import Foundation

protocol StoreType {
    var key: String { get }
    var limit: Int { get }
    var addFirst: Bool { get }
}

struct FavoriteExpressionImpl: StoreType {
    let key = "FavoriteExpressionKey"
    var limit: Int = LocalExpressionConfig.data.favoriteLimit
    var addFirst: Bool = true
}

struct RecenntExpressionImpl: StoreType {
    let key = "RecentExpressionKey"
    var limit: Int = LocalExpressionConfig.data.recentLimit
    var addFirst: Bool = true
}

struct ZipExpressionImpl: StoreType {
    let key = "ZipExpressionKey"
    var limit: Int = LocalExpressionConfig.data.zipLimit
    var addFirst: Bool = false
}

let favoriteExpressionImpl = FavoriteExpressionImpl()
let recenntExpressionImpl = RecenntExpressionImpl()
let zipExpressionImpl = ZipExpressionImpl()

private extension SettingKey {
    
    enum Expression: String {
        case favorite = "FavoriteExpressionKey"
        case recent = "RecentExpressionKey"
        case zip = "ZipExpressionKey"
    }
}

public enum LocalExpressionStore {
    
    case favorite
    case recent
    case zip
    
    var storeImpl: StoreType {
        switch self {
        case .favorite:
            return favoriteExpressionImpl
        case .recent:
            return recenntExpressionImpl
        case .zip:
            return zipExpressionImpl
        }
    }
    
    static var currentAccount: Account? {
        return SessionManager.shared?.accountManager.selectedAccount
    }
    
    @discardableResult
    public func addData(_ id: String) -> Bool {
        guard let account = LocalExpressionStore.currentAccount else {return false}
        if var ids: [String] = Settings.shared.value(for: storeImpl.key, in: account) {
            if ids.contains(id) {
                return false
            }
            if ids.count + 1 > storeImpl.limit {
                return false
            }
            if storeImpl.addFirst {
                ids.insert(id, at: 0)
            } else {
                ids.append(id)
            }
            Settings.shared.setValue(ids, for: storeImpl.key, in: account)
            return true
        }
        Settings.shared.setValue([id], for: storeImpl.key, in: account)
        return true
    }
    
    @discardableResult
    public func removeData(_ id: String) -> Bool {
        guard let account = LocalExpressionStore.currentAccount else {return false}
        if var ids: [String] = Settings.shared.value(for: storeImpl.key, in: account), ids.contains(id) {
            let index = ids.firstIndex { $0 == id }
            ids.remove(at: index!)
            Settings.shared.setValue(ids, for: storeImpl.key, in: account)
            return true
        }
        return false
    }
    
    /// resort emojj package order
    func move(source: Int, destination: Int) {
        guard let account = LocalExpressionStore.currentAccount else { return }
        if var ids: [String] = Settings.shared.value(for: storeImpl.key, in: account) {
            ids.swapAt(source, destination)
            Settings.shared.setValue(ids, for: storeImpl.key, in: account)
            return
        }
        return
    }
    
    @discardableResult
    public func resetData(_ ids: [String]) -> Bool {
        guard let account = LocalExpressionStore.currentAccount else {return false}
        if ids.count > storeImpl.limit {
            return false
        }
        Settings.shared.setValue(ids, for: storeImpl.key, in: account)
        return true
    }
    
    @discardableResult
    public func removeAllData() -> Bool {
        guard let account = LocalExpressionStore.currentAccount else {return false}
        Settings.shared.setValue([], for: storeImpl.key, in: account)
        return true
    }
    
    @discardableResult
    public func getAllData() -> [String] {
        guard let account = LocalExpressionStore.currentAccount else {return []}
        if let ids: [String] = Settings.shared.value(for: storeImpl.key, in: account) {
            return ids
        }
        return []
    }
    
    @discardableResult
    public func contains(_ id: String) -> Bool {
        guard let account = LocalExpressionStore.currentAccount else {return false}
        if let ids: [String] = Settings.shared.value(for: storeImpl.key, in: account) {
            return ids.contains(id)
        }
        return false
    }
    
}



extension LocalExpressionStore {
    
     static var allExpressionDataKey: String {
        return "allExpressionDataKey"
    }
    
    static public func saveExpression(_ data: [String: Any]) {
        guard let account = LocalExpressionStore.currentAccount else {return}
        Settings.shared.setValue(data, for: allExpressionDataKey, in: account)
    }
    
    static public func getExpression() -> [String: Any]? {
        guard let account = LocalExpressionStore.currentAccount else {return nil}
        let data: [String: Any]? =  Settings.shared.value(for: allExpressionDataKey, in: account)
        return data
    }
    
}
