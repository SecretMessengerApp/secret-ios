
import Foundation

protocol InputLanguageSettable {
    var language: String? {get set}
    var originalTextInputMode: UITextInputMode? {get}
}

extension TextView: InputLanguageSettable {

    var originalTextInputMode: UITextInputMode? {
        get {
            return super.textInputMode
        }
    }

    var overriddenTextInputMode: UITextInputMode? {
        get {
            guard let language = language, language.count > 0 else {
                return super.textInputMode
            }

            for textInputMode: UITextInputMode in UITextInputMode.activeInputModes {
                if textInputMode.primaryLanguage == language {
                    return textInputMode
                }
            }

            return super.textInputMode
        }
    }
}

