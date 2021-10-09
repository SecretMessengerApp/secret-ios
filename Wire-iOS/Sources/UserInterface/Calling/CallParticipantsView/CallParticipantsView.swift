
import Foundation

typealias CallParticipantsList = [CallParticipantsCellConfiguration]

protocol CallParticipantsCellConfigurationConfigurable: Reusable {
    func configure(with configuration: CallParticipantsCellConfiguration, variant: ColorSchemeVariant)
}

enum CallParticipantsCellConfiguration: Hashable {
    case callParticipant(user: ZMUser, sendsVideo: Bool)
    case showAll(totalCount: Int)
    
    var cellType: CallParticipantsCellConfigurationConfigurable.Type {
        switch self {
        case .callParticipant: return UserCell.self
        case .showAll: return ShowAllParticipantsCell.self
        }
    }
    
    // MARK: - Convenience
    
    static var allCellTypes: [UICollectionViewCell.Type] {
        return [
            UserCell.self,
            ShowAllParticipantsCell.self,
        ]
    }
    
    static func prepare(_ collectionView: UICollectionView) {
        allCellTypes.forEach {
            collectionView.register($0, forCellWithReuseIdentifier: $0.reuseIdentifier)
        }
    }
}

class CallParticipantsView: UICollectionView, Themeable {
    
    var rows = CallParticipantsList() {
        didSet {
            reloadData()
        }
    }
    
    @objc dynamic var colorSchemeVariant: ColorSchemeVariant = ColorScheme.default.variant {
        didSet {
            guard oldValue != colorSchemeVariant else { return }
            applyColorScheme(colorSchemeVariant)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.any {
            !$0.isHidden && $0.point(inside: convert(point, to: $0), with: event)
        }
    }
    
    func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        reloadData()
    }
    
    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        self.dataSource = self
        backgroundColor = .clear
        isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CallParticipantsView: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellConfiguration = rows[indexPath.row]
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: cellConfiguration.cellType.reuseIdentifier, for: indexPath)

        if let configurableCell = cell as? CallParticipantsCellConfigurationConfigurable {
            configurableCell.configure(with: cellConfiguration, variant: colorSchemeVariant)
        }
        
        return cell
    }
    
}

extension UserCell: CallParticipantsCellConfigurationConfigurable {
    
    func configure(with configuration: CallParticipantsCellConfiguration, variant: ColorSchemeVariant) {
        guard case let .callParticipant(user, sendsVideo) = configuration else { preconditionFailure() }
        colorSchemeVariant = variant
        contentBackgroundColor = .clear
        hidesSubtitle = true
        configure(with: user)
        accessoryIconView.isHidden = true
        videoIconView.isHidden = !sendsVideo
    }
    
}
