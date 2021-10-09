
import Foundation

protocol CellConfigurationConfigurable: Reusable {
    func configure(with configuration: CellConfiguration, variant: ColorSchemeVariant)
}

enum CellConfiguration {
    typealias Action = (UIView?) -> Void
    case toggle(title: String, subtitle: String, identifier: String, get: () -> Bool, set: (Bool) -> Void)
    case linkHeader
    case leadingButton(title: String, identifier: String, action: Action)
    case loading
    case text(String)
    case iconAction(title: String, icon: StyleKitIcon, color: UIColor?, action: Action)
    
    var cellType: CellConfigurationConfigurable.Type {
        switch self {
        case .toggle: return ToggleSubtitleCell.self
        case .linkHeader: return LinkHeaderCell.self
        case .leadingButton: return ActionCell.self
        case .loading: return LoadingIndicatorCell.self
        case .text: return TextCell.self
        case .iconAction: return IconActionCell.self
        }
    }
    
    var action: Action? {
        switch self {
        case .toggle, .linkHeader, .loading, .text: return nil
        case let .leadingButton(_, _, action: action): return action
        case let .iconAction(_, _, _, action: action): return action
        }
    }
    
    // MARK: - Convenience
    
    static var allCellTypes: [UITableViewCell.Type] {
        return [
            ToggleSubtitleCell.self,
            LinkHeaderCell.self,
            ActionCell.self,
            LoadingIndicatorCell.self,
            TextCell.self,
            IconActionCell.self
        ]
    }
    
    static func prepare(_ tableView: UITableView) {
        allCellTypes.forEach {
            tableView.register($0, forCellReuseIdentifier: $0.reuseIdentifier)
        }
    }

}
