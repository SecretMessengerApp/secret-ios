
import UIKit
import Cartography

final class LoadingIndicatorCell: UITableViewCell, CellConfigurationConfigurable {
    
    private let spinner = ProgressSpinner()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(spinner)
        backgroundColor = .clear
        spinner.hidesWhenStopped = false
        constrain(contentView, spinner) { contentView, spinner in
            spinner.edges == contentView.edges
            spinner.height == 120
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with configuration: CellConfiguration, variant: ColorSchemeVariant) {
        spinner.color = UIColor.dynamic(scheme: .title)
        spinner.isAnimating = false
        spinner.isAnimating = true
    }

}
