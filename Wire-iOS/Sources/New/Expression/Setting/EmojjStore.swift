
import UIKit

class EmojjStore {
    typealias ItemType = ExpressionZip
    
    public enum SectionType {
        case popular
        case my
        case downloaded
    }
    
    public class Section {
        var name: String
        var type: SectionType
        var items: [ItemType]?
        
        init(type: SectionType, name: String, items: [ItemType]?) {
            self.name = name
            self.type = type
            self.items = items
        }
    }
    
    public var sections = [Section]()
    
    private var myEmojjs = [ItemType]()
    private var downloadedEmojjs = [ItemType]()
    
    public func setup() {
        loadData()
        
        self.sections = [
            Section(type: .popular, name: "", items: nil),
            Section(type: .my, name: "emojj.my.section".localized, items: self.myEmojjs),
            Section(type: .downloaded, name: "", items: self.downloadedEmojjs)
        ]
    }
    
    func loadData() {
        self.myEmojjs = ExpressionModel.shared.getSecretExpressions()
        self.downloadedEmojjs = ExpressionModel.shared.getMyExpressionZips()
    }
    
    public func numberOfRowsInSection(index: Int) -> Int {
        let section = self.sections[index]
        
        if section.type == .popular {
            return 1
        } else {
            return section.items?.count ?? 0
        }
    }
    
    public func deleteRow(at indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        if let id = section.items?[indexPath.row].id {
            LocalExpressionStore.zip.removeData("\(id)")
            section.items?.remove(at: indexPath.row)
        }
    }
    
    public func move(source: IndexPath, destination: IndexPath) {
        guard source.section == destination.section else { return }
        let section = sections[source.section]
        LocalExpressionStore.zip.move(source: source.row, destination: destination.row)
        section.items?.swapAt(source.row, destination.row)
    }
    
    public func titleOfSection(index: Int) -> String {
        return sections[index].name
    }
    
    public func config(cell: EmojjCell, at indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        
        switch section.type {
        case .popular:
            cell.titleView.font = FontSpec(.normal, .light).font
            cell.titleView.textColor = .dynamic(scheme: .title)
            cell.titleView.text = "emojj.popular.title".localized
            cell.subtitleView.isHidden = false
            cell.accessoryType = .disclosureIndicator
        case .my, .downloaded:
            let model = section.items![indexPath.row]
            cell.titleView.font = FontSpec(.normal, .medium).font
            cell.titleView.textColor = .dynamic(scheme: .title)
            cell.update(title: model.name)
            
            cell.update(subtitle: "stickers_count.emojj.cell".localized(args: model.count))
            cell.update(icon: model.icon)
            cell.accessoryType = .none
        }
    }
}
