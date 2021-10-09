
import UIKit

extension ConversationInputBarViewController {
    
    @objc func expressionButtonPressed(_ sender: IconButton?) {
        configureIndicateButtonStatusToExpression()
        inputBar.switchToExpression()
        presentExpressionKeyboard()
    }
    
    private func presentExpressionKeyboard() {
        mode = .expression
        inputBar.textView.becomeFirstResponder()
    }
    
    @discardableResult
    func createExpressionKeyboardViewController() -> ExpressionKeyboardViewController {
        let controller = ExpressionKeyboardViewController(conversation: conversation)
        
        // TODO: ToSwift this code might be right position
        inputBar.expressionBarView.tapIndexListener = { [weak self] index in
            self?.expressionKeyboardViewController?.scrollToZip(index)
        }
        
        inputBar.expressionBarView.tapSettingListener = { [weak self] in
            let vc = EmojjSettingViewController().wrapInNavigationController()
            self?.present(vc, animated: true, completion: nil)
        }
        
        inputBar.expressionBarView.tapaddListener = { [weak self] in
            let vc = ExpressionAddViewController().wrapInNavigationController()
            self?.present(vc, animated: true, completion: nil)
        }
        controller.selectIndexListener = { [weak self] index in
            self?.inputBar.expressionBarView.selectIndex(index)
        }
        expressionKeyboardViewController = controller
        return controller
    }
}
