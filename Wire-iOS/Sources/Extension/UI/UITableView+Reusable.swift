//
//  UITableView+Ex.swift
//  Wire-iOS
//


import UIKit.UITableView

extension UITableView {
    
    func registerNibCell<T: UITableViewCell>(_ type: T.Type) {
        register(UINib(nibName: "\(type)", bundle: nil),
                 forCellReuseIdentifier: "\(type)")
    }
    
    func registerCell<T: UITableViewCell>(_ type: T.Type) {
        register(type, forCellReuseIdentifier: "\(type)")
    }
    
    func dequeueCell<T: UITableViewCell>(_ type: T.Type) -> T {
        return dequeueReusableCell(withIdentifier: "\(type)") as! T
    }
    
    func dequeueCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withIdentifier: "\(type)", for: indexPath) as! T
    }
}



// MARK: - HeaderFooterView
extension UITableView {
    
    func registerNibHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
        register(UINib(nibName: "\(type)", bundle: nil),
                 forHeaderFooterViewReuseIdentifier: "\(type)")
    }
    
    func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) {
        register(type, forHeaderFooterViewReuseIdentifier: "\(type)")
    }
    
    func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T {
        return dequeueReusableHeaderFooterView(withIdentifier: "\(type)") as! T
    }
}
