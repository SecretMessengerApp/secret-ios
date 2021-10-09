
import Foundation
import WireDataModel

protocol MessageActionResponder: class {
    /// perform an action for the message
    ///
    /// - Parameters:
    ///   - action: a kind of MessageAction
    ///   - message: the ZMConversationMessage to perform the action
    ///   - view: the source view which perfroms the action
    func perform(action: MessageAction, for message: ZMConversationMessage!, view: UIView)
}
