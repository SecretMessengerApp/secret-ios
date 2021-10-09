
import UIKit

class EmojjSettingViewController: UIViewController {
    private let reuseIdentifier = "cell"

    var editItem: UIBarButtonItem!
    var doneItem: UIBarButtonItem!
    
    let store = EmojjStore()
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .grouped)
        v.dataSource = self
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        v.register(EmojjCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        v.isEditing = true
        v.allowsSelectionDuringEditing = true
        v.backgroundColor = .clear
        return v
    }()
    
    var token: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .dynamic(scheme: .groupBackground)
        
        setupViews()
        setupConstraints()
        
        token = NotificationCenter.default.addObserver(forName: expressionZipsChangedNotificationName, object: nil, queue: .main) { [weak self] notification in
            if notification.userInfo == nil {
                self?.reloadData()
            }
        }
        
        BIEvent.track("emojj_setting")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadData()
    }
    
    func reloadData() {
        store.setup()
        tableView.reloadData()
    }
    
    func setupViews() {
        self.title = "emojj.setting.title".localized
        self.navigationItem.rightBarButtonItem = navigationController?.closeItem()

        view.addSubview(tableView)
    }
    
    @objc func btnEditClicked() {
        self.tableView.isEditing = true
        self.navigationItem.rightBarButtonItem = doneItem
    }
    
    @objc func btnDoneClicked() {
        self.tableView.isEditing = false
        self.navigationItem.rightBarButtonItem = editItem
    }
    
    func setupConstraints() {
        tableView.secret.pin()
    }
}

extension EmojjSettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return store.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.numberOfRowsInSection(index: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EmojjCell
        store.config(cell: cell, at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return store.titleOfSection(index: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .dynamic(scheme: .subtitle)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = store.sections[indexPath.section]
        return section.type == .downloaded
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let section = store.sections[indexPath.section]
        return section.type == .downloaded
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        store.move(source: sourceIndexPath, destination: destinationIndexPath)
        ExpressionModel.shared.postExpressionZipChanged()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            store.deleteRow(at: indexPath)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ExpressionModel.shared.postExpressionZipChanged()
        }
    }
    
    // Limit in a section
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        } else {
            return sourceIndexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = self.store.sections[indexPath.section]
        
        if section.type == .popular {
            let vc = EmojjStoreViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            BIEvent.track("emojj_setting_popular")
        } else {
            if let items = section.items, items.count > indexPath.row {
                let model = items[indexPath.row]
                EmojjSheet.show(content: model, in: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = store.sections[indexPath.section]
        if section.type == .popular {
            return 55
        } else {
            return 60
        }
    }
}
