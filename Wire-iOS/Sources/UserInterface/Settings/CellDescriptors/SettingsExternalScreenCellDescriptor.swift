

import Foundation

enum PresentationStyle: Int {
    case modal
    case navigation
}

enum AccessoryViewMode: Int {
    case `default`
    case alwaysShow
    case alwaysHide
}

class SettingsExternalScreenCellDescriptor: SettingsExternalScreenCellDescriptorType, SettingsControllerGeneratorType {
    static let cellType: SettingsTableCell.Type = SettingsGroupCell.self
    var visible: Bool = true
    let title: String
    let detailTitle: String
    let destructive: Bool
    let presentationStyle: PresentationStyle
    let identifier: String?
    let icon: StyleKitIcon?
    var isUserInteractionEnabled: Bool = true

    private let accessoryViewMode: AccessoryViewMode

    weak var group: SettingsGroupCellDescriptorType?
    weak var viewController: UIViewController?
    
    let previewGenerator: PreviewGeneratorType?

    let presentationAction: () -> (UIViewController?)
    
    convenience init(title: String, detailTitle: String = "", presentationAction: @escaping () -> (UIViewController?)) {
        self.init(
            title: title,
            detailTitle: detailTitle,
            isDestructive: false,
            presentationStyle: .navigation,
            identifier: nil,
            presentationAction: presentationAction,
            previewGenerator: nil,
            icon: .none
        )
    }
    
    convenience init(title: String,
                     detailTitle: String = "",
                     isDestructive: Bool,
                     presentationStyle: PresentationStyle,
                     presentationAction: @escaping () -> (UIViewController?),
                     previewGenerator: PreviewGeneratorType? = .none,
                     icon: StyleKitIcon? = nil,
                     accessoryViewMode: AccessoryViewMode = .default) {
        self.init(
            title: title,
            detailTitle: detailTitle,
            isDestructive: isDestructive,
            presentationStyle: presentationStyle,
            identifier: nil,
            presentationAction: presentationAction,
            previewGenerator: previewGenerator,
            icon: icon,
            accessoryViewMode: accessoryViewMode
        )
    }
    
    init(title: String, detailTitle: String = "", isDestructive: Bool, presentationStyle: PresentationStyle, identifier: String?, presentationAction: @escaping () -> (UIViewController?), previewGenerator: PreviewGeneratorType? = .none, icon: StyleKitIcon? = nil, accessoryViewMode: AccessoryViewMode = .default) {
        self.title = title
        self.detailTitle = detailTitle
        self.destructive = isDestructive
        self.presentationStyle = presentationStyle
        self.presentationAction = presentationAction
        self.identifier = identifier
        self.previewGenerator = previewGenerator
        self.icon = icon
        self.accessoryViewMode = accessoryViewMode
    }
    
    func select(_ value: SettingsPropertyValue?) {
        guard let controllerToShow = self.generateViewController() else {
            return
        }
        
        guard self.isUserInteractionEnabled == true else {
            return
        }
        
        switch self.presentationStyle {
        case .modal:
            if controllerToShow.modalPresentationStyle == .popover,
                let sourceView = self.viewController?.view,
                let popoverPresentation = controllerToShow.popoverPresentationController {
                popoverPresentation.sourceView = sourceView
                popoverPresentation.sourceRect = sourceView.bounds
            }

            controllerToShow.modalPresentationCapturesStatusBarAppearance = true
            self.viewController?.present(controllerToShow, animated: true, completion: .none)
            
        case .navigation:
            if let vc = self.viewController, vc.presentingViewController != nil {
                self.viewController?.navigationController?.pushViewController(controllerToShow, animated: true)
            } else {
                self.viewController?.wr_splitViewController?.pushToRightPossible(controllerToShow, from: self.viewController)
            }
        }
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
//        cell.titleColor = UIColor.white
        cell.detailText = self.detailTitle
        
        if let tableCell = cell as? SettingsTableCell {
            tableCell.valueLabel.accessibilityIdentifier = title + "Field"
            tableCell.valueLabel.isAccessibilityElement = true
        }

        if let previewGenerator = self.previewGenerator {
            let preview = previewGenerator(self)
            cell.preview = preview
        }
        cell.icon = self.icon
        if let groupCell = cell as? SettingsGroupCell {
            switch accessoryViewMode {
            case .default:
                if self.presentationStyle == .modal {
                    groupCell.accessoryType = .none
                } else {
                    groupCell.accessoryType = .disclosureIndicator
                }
            case .alwaysHide:
                groupCell.accessoryType = .none
            case .alwaysShow:
                groupCell.accessoryType = .disclosureIndicator
            }
            
        }
    }
    
    func generateViewController() -> UIViewController? {
        return self.presentationAction()
    }
}
