

import UIKit

class LanguageViewController: UITableViewController {
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "self.settings.language.title".localized
        tableView.registerCell(UITableViewCell.self)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 56
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        dataSource = Language.allCases.map { Lan(lan: $0, isSelected: $0 == Language.current) }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: okButton)
    }
    
    @objc private func rightBarButtonItemAction() {
        guard let lan = dataSource.first(where: { $0.isSelected })?.lan else { return }
        Language.current = lan
        AppDelegate.shared.rootViewController.transition(to: .authenticated(completedRegistration: false))
    }
    
    private var dataSource: [Lan] = [] {
        didSet { tableView.reloadData() }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(UITableViewCell.self, for: indexPath)
        let item = dataSource[indexPath.row]
        cell.textLabel?.text = item.lan.title
        cell.textLabel?.textColor = .dynamic(scheme: .title)
        cell.accessoryType = item.isSelected ? .checkmark : .none
        cell.backgroundColor = .dynamic(scheme: .cellBackground)
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        dataSource.first { $0.isSelected }?.isSelected = false
        item.isSelected = true
        tableView.reloadData()
        okButton.isEnabled = Language.current != item.lan
        okButton.setTitleColor(okButton.isEnabled ? .systemGreen : .gray, for: .normal)
    }
    
    private lazy var okButton: UIButton = {
        let okBtn = UIButton()
        okBtn.setTitle("general.ok".localized, for: .normal)
        okBtn.setTitleColor(.gray, for: .normal)
        okBtn.titleLabel?.font = UIFont.normalFont
        okBtn.addTarget(self, action: #selector(rightBarButtonItemAction), for: .touchUpInside)
        okBtn.isEnabled = false
        return okBtn
    }()
}


private class Lan {
    let lan: Language
    var isSelected: Bool
    
    init(lan: Language, isSelected: Bool) {
        self.lan = lan
        self.isSelected = isSelected
    }
}
