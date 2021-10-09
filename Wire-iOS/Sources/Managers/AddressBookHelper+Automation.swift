

import Foundation


extension AutomationHelper : AddressBookHelperConfiguration {
    
    public var shouldPerformAddressBookRemoteSearchEvenOnSimulator: Bool {
        return self.uploadAddressbookOnSimulator
    }

    public var addressBookRemoteSearchTimeInterval: TimeInterval {
        return self.delayInAddressBookRemoteSearch ?? 0
    }
}
