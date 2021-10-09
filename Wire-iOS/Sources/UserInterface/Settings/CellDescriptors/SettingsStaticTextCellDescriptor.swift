
import UIKit

class SettingsStaticTextCellDescriptor: SettingsCellDescriptorType {
    static let cellType: SettingsTableCell.Type = SettingsStaticTextTableCell.self

    var text: String
    
    var onSelectAction: (() -> Void)?

    init(text: String) {
        self.text = text
        self.identifier = .none
        self.previewGenerator = nil
    }

    // MARK: - Configuration

    func featureCell(_ cell: SettingsCellType) {
        cell.titleText = self.text
//        cell.titleColor = .white
    }

    // MARK: - SettingsCellDescriptorType

    var visible: Bool {
        return true
    }


    var title: String {
        return text
    }

    var identifier: String?
    weak var group: SettingsGroupCellDescriptorType?
    var previewGenerator: PreviewGeneratorType?

    func select(_ value: SettingsPropertyValue?) {
        // no-op
        onSelectAction?()
    }

}
