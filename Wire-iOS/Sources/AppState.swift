
import Foundation

enum AppState : Equatable {
    
    case headless
    case authenticated(completedRegistration: Bool)
    case unauthenticated(error : NSError?)
    case blacklisted(jailbroken: Bool)
    case migrating
    case loading(account: Account, from: Account?)
}
