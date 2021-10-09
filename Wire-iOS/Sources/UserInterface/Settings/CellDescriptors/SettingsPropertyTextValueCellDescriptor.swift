

import Foundation
import WireUtilities

private let zmLog = ZMSLog(tag: "UI")

class SettingsPropertyTextValueCellDescriptor: SettingsPropertyCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsTextCell.self
    var title: String {
        get {
            return settingsProperty.propertyName.settingsPropertyLabelText
        }
    }
    var visible: Bool = true
    let identifier: String?
    weak var group: SettingsGroupCellDescriptorType?
    var settingsProperty: SettingsProperty
    
    init(settingsProperty: SettingsProperty, identifier: String? = .none) {
        self.settingsProperty = settingsProperty
        self.identifier = identifier
    }
    
    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = title
        guard let textCell = cell as? SettingsTextCell else { return }

        if let stringValue = settingsProperty.rawValue() as? String {
            textCell.textInput.text = stringValue
        }
        
        if settingsProperty.enabled {
            textCell.textInput.isUserInteractionEnabled = true
            textCell.textInput.accessibilityTraits.remove(.staticText)
            textCell.textInput.accessibilityIdentifier = title + "Field"
        } else {
            textCell.textInput.isUserInteractionEnabled = false
            textCell.textInput.accessibilityTraits.insert(.staticText)
            textCell.textInput.accessibilityIdentifier = title + "FieldDisabled"
        }
        
        textCell.textInput.isAccessibilityElement = true
    }
    
    func select(_ value: SettingsPropertyValue?) {
        if let stringValue = value?.value() as? String {
            
            do {
                try self.settingsProperty << SettingsPropertyValue.string(value: stringValue)
            }
            catch let error as NSError {
                // specific error message for name string is too short
                if error.domain == ZMObjectValidationErrorDomain &&
                    error.code == ZMManagedObjectValidationErrorCode.tooShort.rawValue {
                    UIApplication.shared.topmostViewController(onlyFullScreen: false)?.showAlert(message: "name.guidance.tooshort".localized)
                } else {
                    UIApplication.shared.topmostViewController(onlyFullScreen: false)?.showAlert(for: error)
                }

            }
            catch let generalError {
                zmLog.error("Error setting property: \(generalError)")
            }
        }
    }
}
