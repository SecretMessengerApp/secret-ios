
import UIKit

extension ConversationContentViewController {
    
    private var headerHeight: CGFloat {
        let height: CGFloat = 20

        if tableView.bounds.size.height <= 0 {
            tableView.setNeedsLayout()
            tableView.layoutIfNeeded()
        }

        return tableView.bounds.size.height - height
    }

    func headerViewFrame(view: UIView) -> CGRect {
        
  
        if [.group, .hugeGroup].contains(conversation.conversationType) {
            let h = min(tableView.bounds.width, 400)
            return CGRect(origin: .zero, size: CGSize(width: h, height: h))
        }
        
        let fittingSize = CGSize(width: tableView.bounds.size.width, height: headerHeight)
        let requiredSize = view.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
        return CGRect(origin: .zero, size: requiredSize)
    }

    func updateHeaderHeight() {
        guard let headerView = tableView.tableHeaderView else { return }
        headerView.frame = headerViewFrame(view: headerView)
        tableView.tableHeaderView = headerView
    }
}
