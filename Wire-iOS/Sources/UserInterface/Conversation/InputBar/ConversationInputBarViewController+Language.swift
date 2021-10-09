
import Foundation

extension ConversationInputBarViewController {

    func setupInputLanguageObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(inputModeDidChange(_:)), name: UITextInputMode.currentInputModeDidChangeNotification, object: nil)
    }

    @objc func inputModeDidChange(_ notification: Notification?) {
        guard let keyboardLanguage =  inputBar.textView.originalTextInputMode?.primaryLanguage else { return }
        ZMUserSession.shared()?.enqueueChanges {
            self.conversation.language = keyboardLanguage
            self.setInputLanguage()
        }
    }

    func setInputLanguage() {
        inputBar.textView.language = conversation.language
    }
}
