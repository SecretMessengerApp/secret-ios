//
//  UICollectionView+CLBase.swift
//  CLEmptyViewDemo
//


import UIKit

//MARK:
extension UICollectionView:CLEmptyBaseViewDelegate{
    public func clickEmptyView() {
        config.clEmptyView.showLoading()
        if let callback = config.tapEmptyViewCallback {
            callback()
        }
    }
    

    public func clickFirstButton() {
        config.clEmptyView.showLoading()
        if let callback = config.tapFirstButtonCallback {
            callback()
        }
    }
    

    public func clickSecondButton() {
        config.clEmptyView.showLoading()
        if let callback = config.tapSecondButtonCallback {
            callback()
        }
    }
}
public extension UICollectionView {
    var config : CLConfigEmptyView {
        set {
            objc_setAssociatedObject(self, runtimeKey.tableKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            let config1 = objc_getAssociatedObject(self, runtimeKey.tableKey!) as? CLConfigEmptyView
            if let config1 = config1 {
                return config1
            }
            layoutIfNeeded()
            let emptyView = CLConfigEmptyView()
            emptyView.frame = self.frame
            self.config = emptyView
            failedReload()
            return emptyView
        }
    }
}

