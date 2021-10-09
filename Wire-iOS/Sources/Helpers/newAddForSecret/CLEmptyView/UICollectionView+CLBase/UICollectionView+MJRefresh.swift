//
//  UICollectionView+MJRefresh.swift
//  CLEmptyViewDemo
//


import UIKit
import MJRefresh

extension UICollectionView {
    

    /// - Parameter callback: <#callback description#>
    public func requestData () {
        self.clickEmptyView()
    }
    

    /// - Parameter callback:
    public func addEmptyViewCallback (callback : (()->Void)?) {
        config.tapEmptyViewCallback = callback
    }
    
    
    
    /// - Parameter callback:
    public func addHeaderCallback (callback : @escaping ()->(Void)) {
        self.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            callback()
        })
    }
    
    public func addShakeHeaderCallback (callback : @escaping ()->(Void)) {
        self.mj_header = ShakeMJRefreshNormalHeader.init(refreshingBlock: {
            callback()
        })
    }
    
    public func addFooterCallback (callback : @escaping ()->(Void)) {
        self.mj_footer = MJRefreshAutoFooter.init(refreshingBlock: {
            callback()
        })
    }
    


    ///
    /// - Parameter noMoreData:
    public func successReload(noMoreData : Bool = false ,isRefresh:Bool = true) {
        endRefresh(isRefresh)
        
        if let footer = mj_footer {
            if noMoreData {
                footer.endRefreshingWithNoMoreData()
            }else{
                footer.resetNoMoreData()
            }
        }
    }
    

    public func failedReload () {
        endRefresh(false)
    }
    
    private func endRefresh (_ isReload: Bool) {
        config.clEmptyView.hideLoading()
        
        if let header = mj_header {
            header.endRefreshing()
        }
        if let footer = mj_footer {
            footer.endRefreshing()
        }
        
        if isReload {
            reloadData()
            layoutIfNeeded()
        }
        var rowCount:Int = 0
        for i in 0..<numberOfSections {
            rowCount = numberOfItems(inSection: i)
            if rowCount > 0 { break}
        }
        if rowCount > 0 {
            isScrollEnabled = true
            config.clEmptyView.hideEmpty()
        }else{
            isScrollEnabled = false
            config.clEmptyView.showEmpty()
        }
        
    }
    
}
