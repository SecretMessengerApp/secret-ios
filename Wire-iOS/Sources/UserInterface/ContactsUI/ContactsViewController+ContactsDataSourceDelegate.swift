
import Foundation
import WireDataModel
import UIKit

extension ContactsViewController: ContactsDataSourceDelegate {

    func dataSource(_ dataSource: ContactsDataSource, cellFor user: UserType, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: ContactsCell.self, for: indexPath)
        cell.contentBackgroundColor = .clear
        cell.colorSchemeVariant = .dark
        cell.user = user

        cell.actionButtonHandler = { [weak self] user, action in
            switch action {
            case .open:
                self?.openConversation(for: user)
            case .invite:
                self?.invite(user: user)
            }
        }

        if !cell.actionButton.isHidden {
            cell.action = user.isConnected ? .open : .invite
        }

        return cell
    }

    func dataSource(_ dataSource: ContactsDataSource, didReceiveSearchResult newUser: [UserType]) {
        tableView.reloadData()
        updateEmptyResults(hasResults: !newUser.isEmpty)
    }

}
