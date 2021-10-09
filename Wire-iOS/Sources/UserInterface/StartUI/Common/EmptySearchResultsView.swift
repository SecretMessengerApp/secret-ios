
import Foundation
import UIKit


fileprivate enum EmptySearchResultsViewState {
    case noUsersOrServices
    case everyoneAdded
    case noServicesEnabled
}

enum EmptySearchResultsViewAction: Int {
    case openManageServices
}

extension EmptySearchResultsViewAction {
    var title: String {
        switch self {
        case .openManageServices:
            return "peoplepicker.no_matching_results_services_manage_services_title".localized
        }
    }
}

protocol EmptySearchResultsViewDelegate: class {
    func execute(action: EmptySearchResultsViewAction, from: EmptySearchResultsView)
}

final class EmptySearchResultsView: UIView {
    
    private var state: EmptySearchResultsViewState = .noUsersOrServices {
        didSet {
            if let icon = self.icon {
                iconView.isHidden = false
                iconView.image = icon
            }
            else {
                iconView.isHidden = true
            }
            
            statusLabel.text = self.text
            
            if let action = self.buttonAction {
                actionButton.isHidden = false
                actionButton.setTitle(action.title, for: .normal)
            }
            else {
                actionButton.isHidden = true
            }
        }
    }
    
    func updateStatus(searchingForServices: Bool, hasFilter: Bool) {
        switch (searchingForServices, hasFilter) {
        case (true, false):
            self.state = .noServicesEnabled
        case (_, true):
            self.state = .noUsersOrServices
        case (false, false):
            self.state = .everyoneAdded
        }
    }
    
    private let variant: ColorSchemeVariant
    private let isSelfUserAdmin: Bool
    
    private let stackView: UIStackView
    private let iconView     = UIImageView()
    private let statusLabel  = UILabel()
    private let actionButton: InviteButton
    
    weak var delegate: EmptySearchResultsViewDelegate?
    
    init(variant: ColorSchemeVariant, isSelfUserAdmin: Bool) {
        self.variant = variant
        self.isSelfUserAdmin = isSelfUserAdmin
        stackView = UIStackView()
        actionButton = InviteButton(variant: variant)
        super.init(frame: .zero)
        
        iconView.alpha = 0.24
        
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.axis = .vertical
        stackView.alignment = .center
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        [iconView, statusLabel, actionButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        [iconView, statusLabel, actionButton].forEach(stackView.addArrangedSubview)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate(stackView.centerInSuperview())

        statusLabel.numberOfLines = 0
        statusLabel.preferredMaxLayoutWidth = 200
        statusLabel.textColor = .dynamic(scheme: .title)
        statusLabel.font = FontSpec(.medium, .semibold).font!
        statusLabel.textAlignment = .center
        
        actionButton.accessibilityIdentifier = "button.searchui.open-services-no-results"
        
        actionButton.addCallback(for: .touchUpInside) { [unowned self] _ in
            guard let action = self.buttonAction else {
                return
            }
            self.delegate?.execute(action: action, from: self)
        }
        
        state = .noUsersOrServices
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var text: String {
        switch (state, isSelfUserAdmin) {
        case (.noUsersOrServices, _):
            return "peoplepicker.no_matching_results_after_address_book_upload_title".localized
        case (.everyoneAdded, _):
            return "add_participants.all_contacts_added".localized
        case (.noServicesEnabled, false):
            return "peoplepicker.no_matching_results_services_title".localized
        case (.noServicesEnabled, true):
            return "peoplepicker.no_matching_results_services_admin_title".localized
        }
    }
    
    private var icon: UIImage? {
        switch state {
        case .noServicesEnabled:
            return StyleKitIcon.bot.makeImage(size: .large, color: .dynamic(scheme: .iconNormal))
        default:
            return nil
        }
    }
    
    private var buttonAction: EmptySearchResultsViewAction? {
        switch (state, isSelfUserAdmin) {
        case (.noServicesEnabled, true):
            return .openManageServices
        default:
            return nil
        }
    }
}
