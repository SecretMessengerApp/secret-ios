
import Foundation

extension StartUIViewController {
    func createConstraints() {
        [searchHeaderViewController.view, groupSelector, searchResultsViewController.view].forEach{ $0?.translatesAutoresizingMaskIntoConstraints = false }

        searchHeaderViewController.view.fitInSuperview(exclude: [.bottom])

        if showsGroupSelector {
            NSLayoutConstraint.activate([
                groupSelector.topAnchor.constraint(equalTo: searchHeaderViewController.view.bottomAnchor),
                searchResultsViewController.view.topAnchor.constraint(equalTo: groupSelector.bottomAnchor)
                ])

            groupSelector.fitInSuperview(exclude: [.bottom, .top])
        } else {
            NSLayoutConstraint.activate([
            searchResultsViewController.view.topAnchor.constraint(equalTo: searchHeaderViewController.view.bottomAnchor)
                ])
        }

        searchResultsViewController.view.fitInSuperview(exclude: [.top])
    }

    var showsGroupSelector: Bool {
        return SearchGroup.all.count > 1 && ZMUser.selfUser().canSeeServices
    }
}
