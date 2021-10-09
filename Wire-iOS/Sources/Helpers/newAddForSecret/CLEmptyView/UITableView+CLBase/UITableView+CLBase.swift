//
//  UITableView+CLBase.swift
//  CLEmptyViewDemo
//


import UIKit

//MARK:
extension UITableView:CLEmptyBaseViewDelegate{

    public func clickEmptyView() {
        config.clEmptyView.showLoading()
        if let callback = config.tapEmptyViewCallback {
            callback()
        }
    }
}

public extension UITableView {
    
    var config : CLConfigEmptyView {
        set {
            objc_setAssociatedObject(self, runtimeKey.tableKey!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let config1 = objc_getAssociatedObject(self, runtimeKey.tableKey!) as? CLConfigEmptyView
            if let config1 = config1 {
                return config1
            }
            let emptyView = CLConfigEmptyView()
            emptyView.frame = self.frame
            self.config = emptyView
            return emptyView
        }
    }
}

public class CLConfigEmptyView {
    
    var tapEmptyViewCallback : (()->Void)?
    var tapFirstButtonCallback : (()->Void)?
    var tapSecondButtonCallback : (()->Void)?
    public let clEmptyView:CLEmptyBaseView = CLEmptyBaseView()
    var frame:CGRect = .zero {
        didSet{
            if frame == .zero {
                clEmptyView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            }else{
                clEmptyView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
            }
        }
    }
    
    func resetFrame(with frame: CGRect) {
        clEmptyView.setContentFrame(with: frame)
        clEmptyView.layoutIfNeeded()
    }
    
}

struct runtimeKey {
    static let tableKey = UnsafeRawPointer.init(bitPattern: "CLConfigEmptyView".hashValue)
}

