
import Foundation

extension ConversationContentViewController: UIScrollViewDelegate {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        updateScrollViewWithScrollState(.start)
        removeHighlightsAndMenu()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.showOrHiddenLatestMessageButton()
        dataSource.didScroll(tableView: scrollView as! UITableView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dataSource.scrollViewDidEndDecelerating(scrollView)
 
        updateScrollViewWithScrollState(.end)
        
        self.computeIfEndScrollingWhenDidEndDecelerating(scrollView)
    }
    

    public func computeIfEndScrollingWhenDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollStop {
            self.tableView.isScrolling = false
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
            updateScrollViewWithScrollState(.end)
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop {
                self.tableView.isScrolling = false
            }
        }
    }
}
