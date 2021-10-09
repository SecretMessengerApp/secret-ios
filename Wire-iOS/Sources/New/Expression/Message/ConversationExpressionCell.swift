
import UIKit

class ConversationExpressionCell: UIView, ConversationJsonMessageCellClickProtocol {
        
    var expression: ConversationJSONMessage.Expression?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTapAction(in: self)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func conversationJsonMessageCellClickAction() {
        guard
            let controller = currentViewController(),
            let expression = expression,
            let zipId = expression.zipId, let id = Int(zipId),
            let model = ExpressionModel.shared.getExpressionById(id)
            else { return }
        EmojjSheet.show(content: model, in: controller)
    }
}
