
import UIKit

final class ArrayDataSource<Cell: UITableViewCell, Data>: NSObject, UITableViewDataSource {
    
    var configure: ((Cell, Data) -> Void)?
    var data: [Data] {
        get { return _data }
        set {
            _data = newValue
            tableView.reloadData()
        }
    }
    
    private unowned let tableView: UITableView
    private var _data = [Data]()
    
    func append(_ element: Data) {
        _data.insert(element, at: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    init(for tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        Cell.register(in: tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.zm_reuseIdentifier, for: indexPath) as! Cell
        configure?(cell, _data[indexPath.row])
        return cell
    }

}
