
import Foundation
import Cartography

 final class TextSearchResultsView: UIView {
    internal var tableView = UITableView()
    internal var noResultsView = NoResultsView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        createConstraints()

        backgroundColor = .dynamic(scheme: .barBackground)
    }

    func setupViews() {
        self.tableView.register(TextSearchResultCell.self, forCellReuseIdentifier: TextSearchResultCell.reuseIdentifier)
        self.tableView.estimatedRowHeight = 44
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.backgroundColor = .clear
        self.addSubview(self.tableView)

        self.noResultsView.label.accessibilityLabel = "no text messages"
        self.noResultsView.label.text = "collections.search.no_items".localized(uppercased: true)
        self.noResultsView.icon = .search
        self.addSubview(self.noResultsView)
    }

    func createConstraints() {
        constrain(self, self.tableView, self.noResultsView) { resultsView, tableView, noResultsView in
            tableView.edges == resultsView.edges

            noResultsView.top >= resultsView.top + 12
            noResultsView.bottom <= resultsView.bottom - 12
            noResultsView.center == resultsView.center
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
