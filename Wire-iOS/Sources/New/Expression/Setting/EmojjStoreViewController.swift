
import UIKit

//extension Notification.Name {
//    static let emojjPackagesChanged = Notification.Name("emojjPackagesChanged")
//}

class EmojjStoreViewController: UIViewController {
    typealias EmojjPackage = ExpressionZip
    
    private let reuseIdentifier = "cell"
    private let accessoryView2 = UIButton()
    
    var models = [EmojjPackage]()
    
    lazy var tableView: UITableView = {
        let v = UITableView(frame: .zero, style: .plain)
        v.backgroundColor = .clear
        v.dataSource = self
        v.delegate = self
        v.translatesAutoresizingMaskIntoConstraints = false
        v.register(EmojjCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        return v
    }()
    
    var token: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamic(scheme: .barBackground)
        setupViews()
        setupConstraints()
        reloadData()
        
        token = NotificationCenter.default.addObserver(forName: expressionZipsChangedNotificationName, object: nil, queue: .main) { [weak self] _ in
            self?.reloadData()
        }
    }
    
    func reloadData() {
        self.models = ExpressionModel.shared.getPopularExpression()
        tableView.reloadData()
    }
    
    func setupViews() {
        self.title = "emojj.popular.title".localized
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        self.tableView.secret.pin()
    }
}

extension EmojjStoreViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EmojjCell
        let model = self.models[indexPath.row]
        cell.update(title: model.name)
        cell.update(subtitle: "stickers_count.emojj.cell".localized(args: model.count))
        cell.update(icon: model.icon)
        cell.update(mark: model.shouldAdd ? "plus_blue" : "check_gray")
        cell.onMarkViewClicked = { [unowned self] in
            if model.shouldAdd {
                LocalExpressionStore.zip.addData("\(model.id)")
            } else {
                LocalExpressionStore.zip.removeData("\(model.id)")
            }
            self.reloadData()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.models[indexPath.row]
        EmojjSheet.show(content: model, in: self)
    }
}
