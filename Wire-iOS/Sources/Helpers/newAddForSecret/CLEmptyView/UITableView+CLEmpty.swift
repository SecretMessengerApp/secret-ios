//
//  UITableView+CLEmpty.swift
//  CLEmptyViewDemo
//


import UIKit


extension UITableView {
    /// emptyView
   public func normalEmptyView(){
        config.clEmptyView.addEmptyImage(imageNmae: "secret-launch")
            .addEmptyTis(tips: NSAttributedString(string: "Emptyset.noBillDesciption".localized))
            .addLoadingImage(imageNames: ["loading_imgBlue_78x78"])
            .addLoadingDuration(duration: 0.5)
            .endConfig()
        setUpEmptyView()
    
        addToSuperView()
    }

    fileprivate func setUpEmptyView(){
        tableFooterView = UIView()
        
    }
    
    private func addToSuperView() {
        self.backgroundView = config.clEmptyView
        config.clEmptyView.delegate = self
    }
}

@available(*, deprecated, message: "Do not use this class, it will be deleted in the fututre")
final class AutoHideMJFooterTableView: UITableView {
    
    var isAutoHideMJFooter = true
    
    override func reloadData() {
        super.reloadData()
//        if isAutoHideMJFooter {
//            resetMJFooter()
//        }
    }
    
    private func resetMJFooter() {
        DispatchQueue.main.async {
            let originInset = self.mj_header.scrollViewOriginalInset
            var realHeight = self.frame.height - originInset.top - originInset.bottom
            
            if !self.mj_footer.isHidden {
                realHeight = realHeight + self.mj_footer.frame.height + 10 
            }
            self.mj_footer.isHidden = realHeight >= self.contentSize.height
        }
    }
}
