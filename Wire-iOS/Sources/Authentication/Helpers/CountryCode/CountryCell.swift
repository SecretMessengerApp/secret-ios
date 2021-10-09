
import Foundation
import UIKit

final class CountryCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func configure(for country: Country) {
        textLabel?.text = country.displayName
        detailTextLabel?.text = "+\(country.e164)"

        accessibilityHint = "registration.phone.country_code.hint".localized
    }
}
