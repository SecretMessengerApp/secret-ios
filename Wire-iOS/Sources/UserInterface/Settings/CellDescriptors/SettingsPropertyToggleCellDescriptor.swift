

import Foundation

private let zmLog = ZMSLog(tag: "UI")

/**
 * @abstract Generates the cell that displays toggle control
 */
class SettingsPropertyToggleCellDescriptor: SettingsPropertyCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsToggleCell.self
    let inverse: Bool
    var title: String {
        get {
            return settingsProperty.propertyName.settingsPropertyLabelText
        }
    }
    let identifier: String?
    var visible: Bool = true
    weak var group: SettingsGroupCellDescriptorType?
    var settingsProperty: SettingsProperty
    
    init(settingsProperty: SettingsProperty, inverse: Bool = false, identifier: String? = .none) {
        self.settingsProperty = settingsProperty
        self.inverse = inverse
        self.identifier = identifier
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        if let toggleCell = cell as? SettingsToggleCell {
            var boolValue = false
            if let value = self.settingsProperty.value().value() as? NSNumber {
                boolValue = value.boolValue
            }
            else {
                boolValue = false
            }
            
            if self.inverse {
                boolValue = !boolValue
            }
            
            toggleCell.switchView.isOn = boolValue
            toggleCell.switchView.accessibilityLabel = identifier
            toggleCell.switchView.isEnabled = self.settingsProperty.enabled
        }
    }
    
    func select(_ value: SettingsPropertyValue?) {
        var valueToSet = false
        
        if let value = value?.value() {
            switch value {
            case let numberValue as NSNumber:
                valueToSet = numberValue.boolValue
            case let intValue as Int:
                valueToSet = intValue > 0
            case let boolValue as Bool:
                valueToSet = boolValue
            default:
                fatal("Unknown type: \(type(of: value))")
            }
        }
        
        if self.inverse {
            valueToSet = !valueToSet
        }
        
        do {
            try self.settingsProperty << SettingsPropertyValue(valueToSet)
        }
        catch(let e) {
            zmLog.error("Cannot set property: \(e)")
        }
    }
}


class SettingsPropertyToggle2CellDescriptor: SettingsPropertyCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsToggleCell.self
    let inverse: Bool
    var title: String {
        get {
            return self.settingsProperty.propertyName.settingsPropertyLabelText
        }
    }
    let identifier: String?
    var visible: Bool = true
    weak var group: SettingsGroupCellDescriptorType?
    var settingsProperty: SettingsProperty
    
    init(settingsProperty: SettingsProperty, inverse: Bool = false, identifier: String? = .none) {
        self.settingsProperty = settingsProperty
        self.inverse = inverse
        self.identifier = identifier
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.title
        if let toggleCell = cell as? SettingsToggleCell {
            var boolValue = false
            if let value = self.settingsProperty.value().value() as? NSNumber {
                boolValue = !(value.int64Value == 0)
            }
            else {
                boolValue = false
            }
            
            if self.inverse {
                boolValue = !boolValue
            }
            
            toggleCell.switchView.isOn = boolValue
            toggleCell.switchView.accessibilityLabel = identifier
        }
    }
    
    func select(_ value: SettingsPropertyValue?) {
        var valueToSet: Int64 = 0
        
        if let value = value?.value() {
            switch value {
            case let numberValue as NSNumber:
                valueToSet = numberValue.int64Value == 1 ? -1 : 0
            default:
                fatal("Unknown type: \(type(of: value))")
            }
        }
        
        do {
            try self.settingsProperty << SettingsPropertyValue(valueToSet)
        }
        catch(let e) {
            zmLog.error("Cannot set property: \(e)")
        }
    }
}
