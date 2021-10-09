
import Foundation
import WireUtilities

@objc
protocol UserSelectionObserver {
    
    func userSelection(_ userSelection: UserSelection, didAddUser user: ZMUser)
    func userSelection(_ userSelection: UserSelection, didRemoveUser user: ZMUser)
    func userSelection(_ userSelection: UserSelection, wasReplacedBy users: [ZMUser])
    @objc optional func userSelectionRemoveAll()
}


class UserSelection : NSObject {
    
    fileprivate(set) var users : Set<ZMUser> = Set()
    fileprivate var observers : [UnownedObject<UserSelectionObserver>] = []
    
    func replace(_ users: [ZMUser]) {
        self.users = Set(users)
        observers.forEach({ $0.unbox?.userSelection(self, wasReplacedBy: users) })
    }
    
    func add(_ user: ZMUser) {
        users.insert(user)
        observers.forEach({ $0.unbox?.userSelection(self, didAddUser: user) })
    }
    
    func remove(_ user: ZMUser) {
        users.remove(user)
        observers.forEach({ $0.unbox?.userSelection(self, didRemoveUser: user) })
    }
    
    func removeAll() {
        guard users.count > 0 else {
            return
        }
        users.forEach({self.remove($0)})
        observers.forEach({ $0.unbox?.userSelectionRemoveAll?()})
    }
    
    @objc(addObserver:)
    func add(observer: UserSelectionObserver) {
        guard !observers.contains(where: { $0.unbox === observer}) else { return }
        
        observers.append(UnownedObject(observer))
    }
    
    @objc(removeObserver:)
    func remove(observer: UserSelectionObserver) {
        guard let index = observers.firstIndex(where: { $0.unbox === observer}) else { return }
        
        observers.remove(at: index)
    }
    
    // MARK: - Limit
    
    private(set) var limit: Int?
    private var limitReachedHandler: (() -> Void)?
    
    var hasReachedLimit: Bool {
        guard let limit = limit, users.count >= limit else { return false }
        limitReachedHandler?()
        return true
    }
    
    func setLimit(_ limit: Int, handler: @escaping () -> Void) {
        self.limit = limit
        self.limitReachedHandler = handler
    }
}
