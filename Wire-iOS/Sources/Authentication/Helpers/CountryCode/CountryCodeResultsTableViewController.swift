
import UIKit

final class CountryCodeResultsTableViewController: UITableViewController {
    var filteredCountries: [Country]?

    override func viewDidLoad() {
        super.viewDidLoad()

        CountryCell.register(in: tableView)
    }

    // MARK: - TableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ofType: CountryCell.self, for: indexPath)

        if let country = filteredCountries?[indexPath.row] {
            cell.configure(for: country)
        }

        return cell
    }
}
