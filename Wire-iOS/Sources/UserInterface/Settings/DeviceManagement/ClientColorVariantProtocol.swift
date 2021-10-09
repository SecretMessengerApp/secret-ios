
import Foundation

protocol ClientListViewControllerDelegate: class {
    func finishedDeleting(_ clientListViewController: ClientListViewController)
}

protocol ClientColorVariantProtocol {
    var variant: ColorSchemeVariant? { get set }
    var headerFooterViewTextColor: UIColor { get }
    var separatorColor: UIColor { get }
    func setColor(for variant: ColorSchemeVariant?)
}

extension ClientColorVariantProtocol where Self: UIViewController {

    var headerFooterViewTextColor: UIColor {
        get {
            switch variant {
            case .none, .dark?:
                return UIColor(white: 1, alpha: 0.4)
            case .light?:
                return UIColor.dynamic(scheme: .title)
            }
        }
    }

    var separatorColor: UIColor {
        .dynamic(scheme: .separator)
    }

    func setColor(for variant: ColorSchemeVariant?) {
        switch variant {
        case .none:
            view.backgroundColor = .clear
        case .dark?:
            view.backgroundColor = .black
        case .light?:
            view.backgroundColor = UIColor.dynamic(scheme: .background)
        }
    }
}
