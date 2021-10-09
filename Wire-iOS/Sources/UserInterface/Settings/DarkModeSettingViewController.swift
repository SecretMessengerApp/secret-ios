

import UIKit

@available(iOS 13.0, *)
class DarkModeSettingViewController: SettingsBaseTableViewController {
    
    enum Section {
        case system([Cell])
        case manual([Cell])
        
        var rows: Int {
            switch self {
            case .system: return 1
            case .manual: return 2
            }
        }
        
        func cellType(at indexPath: IndexPath) -> UITableViewCell.Type {
            switch self {
            case .system(let cells), .manual(let cells):
                return cells[indexPath.row].cellType
            }
        }
        
        func cell(at indexPath: IndexPath) -> Cell {
            switch self {
            case .system(let cells), .manual(let cells):
                return cells[indexPath.row]
            }
        }
        
        enum Cell {
            case system(Bool), light(Bool), dark(Bool)
            
            static var allCases: [Cell] {
                [.system(true), .light(false), .dark(false)]
            }
            
            var cellType: UITableViewCell.Type {
                switch self {
                case .system: return FollowSystemCell.self
                case .light: return LightCell.self
                case .dark: return DarkCell.self
                }
            }
        }
    }
    
    override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "self.settings.dark_mode.title".localized
        Section.Cell.allCases.forEach { tableView.registerCell($0.cellType) }
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 56
        
        switch AppTheme.current {
        case .unspecified: sections = [.system([.system(true)])]
        case .light: sections = [.system([.system(false)]), .manual([.light(true), .dark(false)])]
        case .dark: sections = [.system([.system(false)]), .manual([.light(false), .dark(true)])]
        }
    }
    
    private var sections: [Section] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = sections[indexPath.section].cellType(at: indexPath)
        let cell = tableView.dequeueCell(type, for: indexPath)
        cell.backgroundColor = .dynamic(scheme: .cellBackground)
        let ce = sections[indexPath.section].cell(at: indexPath)
        switch (ce, cell) {
        case (.system(let value), let cell as FollowSystemCell):
            cell.toggle.isOn = value
            cell.switchValueChanged = { [weak self] isOn in
                if isOn {
                    AppTheme.switch(to: .unspecified)
                    self?.sections = [.system([.system(true)])]
                } else {
                    if UITraitCollection.current.userInterfaceStyle == .dark {
                        AppTheme.switch(to: .dark)
                        self?.sections = [.system([.system(false)]), .manual([.light(false), .dark(true)])]
                    } else {
                        AppTheme.switch(to: .light)
                        self?.sections = [.system([.system(false)]), .manual([.light(true), .dark(false)])]
                    }
                }
            }
        case (.light(let value), let cell as LightCell):
            cell.accessoryType = value ? .checkmark : .none
        case (.dark(let value), let cell as DarkCell):
            cell.accessoryType = value ? .checkmark : .none
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard case .manual = sections[section] else { return nil }
        return "self.settings.dark_mode.manual.title".localized
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = sections[indexPath.section].cell(at: indexPath)
        switch cell {
        case .system: break
        case .light:
            AppTheme.switch(to: .light)
            sections = [.system([.system(false)]), .manual([.light(true), .dark(false)])]
        case .dark:
            AppTheme.switch(to: .dark)
            sections = [.system([.system(false)]), .manual([.light(false), .dark(true)])]
        }
    }
}


private class FollowSystemCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        textLabel?.text = "self.settings.dark_mode.state_system.title".localized
        textLabel?.textColor = .dynamic(scheme: .title)
        detailTextLabel?.text = "self.settings.dark_mode.state_system.desc".localized
        detailTextLabel?.textColor = .dynamic(scheme: .subtitle)
        accessoryView = toggle
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var switchValueChanged: ((Bool) -> Void)?
    
    @objc private func switchChanged() {
        switchValueChanged?(toggle.isOn)
    }
    
    let toggle = UISwitch()
}


private class LightCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = "self.settings.dark_mode.state_light.title".localized
        textLabel?.textColor = .dynamic(scheme: .title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class DarkCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.text = "self.settings.dark_mode.state_dark.title".localized
        textLabel?.textColor = .dynamic(scheme: .title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
