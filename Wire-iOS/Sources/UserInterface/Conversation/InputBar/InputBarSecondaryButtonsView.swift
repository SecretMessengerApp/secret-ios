
import UIKit
import Cartography

// Acts as a container for InputBarEditView & MarkdownBarView, however
// only one of the views will be in the view hierarchy at a time.
//
final class InputBarSecondaryButtonsView: UIView {
    
    let editBarView: InputBarEditView
    let markdownBarView: MarkdownBarView
    let expressionBarView: ExpressionBarView
    
    init(editBarView: InputBarEditView, markdownBarView: MarkdownBarView, expressionBarView: ExpressionBarView) {
        self.editBarView = editBarView
        self.markdownBarView = markdownBarView
        self.expressionBarView = expressionBarView
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setView(_ newView: UIView) {
        
        // only if newView isnt already a subview
        guard !newView.isDescendant(of: self) else { return }
        
        subviews.forEach { $0.removeFromSuperview() }
        addSubview(newView)
        
        constrain(self, newView) { view, newView in
            newView.edges == view.edges
        }
    }
    
    func setEditBarView() {
        setView(editBarView)
    }
    
    func setMarkdownBarView() {
        setView(markdownBarView)
    }
    
    func setExpressionBarView() {
        setView(expressionBarView)
    }
}
