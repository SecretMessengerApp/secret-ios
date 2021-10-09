
import Foundation

protocol TokenFieldDelegate: class {
    func tokenField(_ tokenField: TokenField, changedTokensTo tokens: [Token<NSObjectProtocol>])
    func tokenField(_ tokenField: TokenField, changedFilterTextTo text: String)
    func tokenFieldDidConfirmSelection(_ controller: TokenField)
}
