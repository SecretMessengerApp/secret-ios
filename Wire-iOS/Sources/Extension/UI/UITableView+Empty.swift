//
//  UITableView+Empty.swift
//  Wire-iOS
//


import Foundation

extension UITableView {
    

    enum EmptyStyle {
        case `default`
        case search
        case currency
        case moment
        case custom(String)
        
        var text: String {
            switch self {
            case .`default`:
                return "peoplepicker.no_matching_results_title".localized
            case .search:
                return "peoplepicker.no_matching_results_title".localized
            case .currency:
                return "peoplepicker.no_matching_results_title".localized
            case .moment:
                return "peoplepicker.no_matching_results_title".localized
            case .custom(let str):
                return str.localized
            }
        }
    }
    
    func setEmpty(with count: Int, style: EmptyStyle = .default) {
        if count == 0 {
            let emptyTitleLabel = UILabel()
            emptyTitleLabel.text = style.text
            emptyTitleLabel.font = UIFont(16, .medium)
            emptyTitleLabel.textColor = .dynamic(scheme: .subtitle)
            emptyTitleLabel.textAlignment = .center
            self.backgroundView = emptyTitleLabel
        } else {
            self.backgroundView = UIView()
        }
    }
    
}
