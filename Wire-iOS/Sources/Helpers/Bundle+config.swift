

import Foundation

extension Bundle {    
    static var developerModeEnabled: Bool {
        return Bundle.appMainBundle.infoForKey("EnableDeveloperMenu") == "1"
    }
}
