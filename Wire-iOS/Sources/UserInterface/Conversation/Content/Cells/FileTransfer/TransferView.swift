
import Foundation
import WireDataModel

protocol TransferViewDelegate: class {
    func transferView(_ view: TransferView, didSelect: MessageAction)
}

protocol TransferView {
    var delegate: TransferViewDelegate? { get set }
    var fileMessage: ZMConversationMessage? { get set }
    func configure(for: ZMConversationMessage, isInitial: Bool)
}

