
import Foundation

extension ContactsViewController: SearchHeaderViewControllerDelegate {

    public func searchHeaderViewController(_ searchHeaderViewController: SearchHeaderViewController,
                                           updatedSearchQuery query: String) {
        dataSource.searchQuery = query
    }

    public func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController: SearchHeaderViewController) {
        // No op
    }
}
