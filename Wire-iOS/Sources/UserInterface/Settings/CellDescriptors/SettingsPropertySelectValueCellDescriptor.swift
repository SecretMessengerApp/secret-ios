

import Foundation

private let zmLog = ZMSLog(tag: "UI")

class SettingsPropertySelectValueCellDescriptor: SettingsPropertyCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsValueCell.self
    let value: SettingsPropertyValue
    let title: String
    let identifier: String?
    
    typealias SelectActionType = (SettingsPropertySelectValueCellDescriptor) -> ()
    let selectAction: SelectActionType?
    let backgroundColor: UIColor?
    var visible: Bool = true

    weak var group: SettingsGroupCellDescriptorType?
    var settingsProperty: SettingsProperty
    
    init(settingsProperty: SettingsProperty, value: SettingsPropertyValue, title: String, identifier: String? = .none, selectAction: SelectActionType? = .none, backgroundColor: UIColor? = .none) {
        self.settingsProperty = settingsProperty
        self.value = value
        self.title = title
        self.identifier = identifier
        self.selectAction = selectAction
        self.backgroundColor = backgroundColor
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        cell.cellColor = self.backgroundColor
        if let valueCell = cell as? SettingsValueCell {
            valueCell.accessoryType = self.settingsProperty.value() == self.value ? .checkmark : .none
        }
    }
    
    func select(_ value: SettingsPropertyValue?) {
        do {
            try self.settingsProperty.set(newValue: self.value)
        }
        catch (let e) {
            zmLog.error("Cannot set property: \(e)")
        }
        if let selectAction = self.selectAction {
            selectAction(self)
        }
    }
}
