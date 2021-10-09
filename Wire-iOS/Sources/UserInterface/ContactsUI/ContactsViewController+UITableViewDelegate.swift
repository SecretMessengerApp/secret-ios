
import Foundation

extension ContactsViewController: UITableViewDelegate {

    func headerTitle(section: Int) -> String? {
        return dataSource.tableView(tableView, titleForHeaderInSection: section)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = headerTitle(section: section), title.count > 0 else { return nil }
        let headerView = tableView.dequeueHeaderFooterView(ContactsSectionHeaderView.self)
        headerView.label.text = title
        return headerView
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = headerTitle(section: section), title.count > 0 else { return 0 }
        return ContactsSectionHeaderView.height
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat.StartUI.CellHeight
    }
}
