
final class CollectionViewContainerCell: UICollectionViewCell {
    var collectionView: UICollectionView? {
        didSet {
            guard let collectionView = collectionView else { return }

            contentView.addSubview(collectionView)

            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.fitInSuperview()
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "topPeopleSection"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
