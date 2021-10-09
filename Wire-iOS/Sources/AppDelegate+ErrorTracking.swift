

import Foundation

extension AppDelegate {
    
    func trackErrors() {
        ZMUserSession.shared()?.registerForSaveFailure(handler: { (metadata, type, error, userInfo) in
            let name = "debug.database_context_save_failure"
            let attributes = [
                "context_type" : type.rawValue,
                "error_code" : error.code,
                "error_domain" : error.domain,
            ] as [String: Any]
            
            DispatchQueue.main.async {
                Analytics.shared().tagEvent(name, attributes: attributes)
            }
        })
    }
    
}
