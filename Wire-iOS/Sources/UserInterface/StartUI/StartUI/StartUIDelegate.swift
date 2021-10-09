
import Foundation
import WireDataModel

protocol StartUIDelegate: class {
    func startUI(_ startUI: StartUIViewController, didSelect user: UserType)
    func startUI(_ startUI: StartUIViewController, didSelect conversation: ZMConversation)
    func startUI(_ startUI: StartUIViewController,
                 createConversationWith users: UserSet,
                 name: String,
                 allowGuests: Bool,
                 enableReceipts: Bool)
}
