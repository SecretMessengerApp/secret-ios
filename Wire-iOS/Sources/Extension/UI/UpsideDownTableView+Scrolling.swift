//
//  UpsideDownTableView+Scrolling.swift
//  Wire-iOS
//


import Foundation

extension UpsideDownTableView {
    @objc(scrollToBottomAnimated:)
    func scrollToBottom(animated: Bool) {
        self.lockContentOffsetWhenNewMessageCome = false
        // kill existing scrolling animation
        self.setContentOffset(self.contentOffset, animated: false)
        // scroll to bottom
        self.setContentOffset(CGPoint(x: 0, y: -self.correctedContentInset.bottom), animated: animated)
    }
    
    func scrollToBottomNoAnimation() {
        // kill existing scrolling animation
        self.setContentOffset(self.contentOffset, animated: false)
        self.lockContentOffsetWhenNewMessageCome = false
        self.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: false)
    }
    
    func scroll(toIndex indexToShow: Int, completion: ((UIView)->())? = .none) {
        guard numberOfSections > 0 else { return }
        
        let rowIndex = numberOfCells(inSection: indexToShow) - 1
        guard rowIndex >= 0 else { return }
        let cellIndexPath = IndexPath(row: rowIndex, section: indexToShow)
        
        scrollToRow(at: cellIndexPath, at: .top, animated: false)
        if let cell = cellForRow(at: cellIndexPath) {
            completion?(cell)
        }
    }
}

private extension UITableView {
    func scrollToTop(animated: Bool) {
        // kill existing scrolling animation
        self.setContentOffset(self.contentOffset, animated: false)
        
        // scroll completely to top
        self.setContentOffset(CGPoint(x: 0, y: -self.contentInset.top), animated:animated)
    }
}
