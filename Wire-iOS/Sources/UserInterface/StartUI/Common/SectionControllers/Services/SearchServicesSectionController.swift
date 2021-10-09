

import Foundation

protocol SearchServicesSectionDelegate: SearchSectionControllerDelegate {
    func addServicesSectionDidRequestOpenServicesAdmin()
}

class SearchServicesSectionController: SearchSectionController {
    
    weak var delegate: SearchServicesSectionDelegate? = nil

    var services: [ServiceUser] = []

    let canSelfUserManageTeam: Bool

    init(canSelfUserManageTeam: Bool) {
        self.canSelfUserManageTeam = canSelfUserManageTeam
        super.init()
    }
    
    override var isHidden: Bool {
        return services.isEmpty
    }
    
    override func prepareForUse(in collectionView: UICollectionView?) {
        collectionView?.register(OpenServicesAdminCell.self, forCellWithReuseIdentifier: OpenServicesAdminCell.zm_reuseIdentifier)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if canSelfUserManageTeam {
            return services.count + 1
        }
        else {
            return services.count
        }
    }
    
    override var sectionTitle: String {
        return "peoplepicker.header.services".localized
    }
    
    func service(for indexPath: IndexPath) -> ServiceUser {
        if canSelfUserManageTeam {
            return services[indexPath.row - 1]
        }
        else {
            return services[indexPath.row]
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if canSelfUserManageTeam && indexPath.row == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: OpenServicesAdminCell.zm_reuseIdentifier, for: indexPath)
        }
        else {
            let service = self.service(for: indexPath)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCell.zm_reuseIdentifier, for: indexPath) as! UserCell
            
            cell.configure(with: service)
            cell.accessoryIconView.isHidden = false
            cell.showSeparator = (services.count - 1) != indexPath.row
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if canSelfUserManageTeam && indexPath.row == 0 {
            delegate?.addServicesSectionDidRequestOpenServicesAdmin()
        }
        else {
            let service = self.service(for: indexPath)
            delegate?.searchSectionController(self, didSelectUser: service, at: indexPath)
        }
    }
    
}
