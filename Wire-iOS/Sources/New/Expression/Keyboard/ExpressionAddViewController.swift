
import Foundation

final class ExpressionAddViewController: UITableViewController {
    
    private var datas: [ExpressionZip]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "expression.add.title".localized
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .dynamic(scheme: .barBackground)
        tableView.registerCell(ExpressionKeyboardAddCell.self)
        tableView.estimatedRowHeight = 200
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
        setupDatas()
    }
    
    private func setupDatas() {
        datas = ExpressionModel.shared.getNotDefaultExpression()
        tableView.reloadData()
    }
    
    private func setCellListeners(cell: ExpressionKeyboardAddCell) {
        cell.singleTapListener = { [weak self] zip in
            self?.showSheet(zip: zip)
        }
    }
    
    private func showSheet(zip: ExpressionZip) {
        EmojjSheet.show(content: zip, in: self)
    }
}

extension ExpressionAddViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ExpressionKeyboardAddCell.self, for: indexPath)
        let zip = self.datas?[indexPath.row]
        guard let zi = zip else {return UITableViewCell()}
        cell.setZip(zi)
        self.setCellListeners(cell: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let zip = self.datas?[indexPath.row]
        guard let zi = zip else {return}
        self.showSheet(zip: zi)
    }
}
