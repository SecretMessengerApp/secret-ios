
import Foundation

protocol TextFieldable {
    var textField: AccessoryTextField? { get set }
    var editingChangedListener: ((String?) -> Void)? { get set }
}

extension TextFieldDescription : TextFieldable {}

extension VerifyCodeTextFieldDescription : TextFieldable {}
