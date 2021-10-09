
import UIKit
import SDWebImage
import FLAnimatedImage
import SSticker

class ExpressionKeyboardAddCell: UITableViewCell {
    
    public var addTapListener: ((ExpressionZip) -> Void)?
    public var singleTapListener: ((ExpressionZip) -> Void)?
    
    let itemWidth = UIScreen.main.bounds.width / 6
    var zip: ExpressionZip?
    var items: [ExpressionItem] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(addButton)
        selectionStyle = .none
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setZip(_ zip: ExpressionZip) {
        self.zip = zip
        if zip.gifs.count > 5 {
            self.items = Array(zip.gifs[0...4])
        } else {
            self.items = zip.gifs
        }
        if LocalExpressionStore.zip.contains("\(zip.id)") {
            self.selectButton()
        } else {
            self.unselectButton()
        }
        self.titleLabel.text = zip.name
        subtitleLabel.text = "\(zip.count) stickers"
        self.collectionView.reloadData()
    }
    
    private func createConstraints() {
        var constraints = [
            titleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            
            subtitleLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 6)
        ]
        constraints += [
            collectionView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            collectionView.heightAnchor.constraint(equalToConstant: itemWidth),
            collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)
        ]
        constraints += [
            addButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
//            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 28)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func tapAdd() {
        guard let z = self.zip else {return}
        if LocalExpressionStore.zip.contains("\(z.id)") {
            LocalExpressionStore.zip.removeData("\(z.id)")
            unselectButton()
        } else {
            LocalExpressionStore.zip.addData("\(z.id)")
            selectButton()
        }
        ExpressionModel.shared.postExpressionZipChanged()
    }
    
    func selectButton() {
        UIView.animate(withDuration: 0.3) {
            self.addButton.isSelected = true
            self.addButton.backgroundColor = UIColor(hex: "#DCEEFF")
        }
    }
    
    func unselectButton() {
        UIView.animate(withDuration: 0.3) {
            self.addButton.isSelected = false
            self.addButton.backgroundColor = .dynamic(scheme: .brand)
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .dynamic(scheme: .title)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textColor = .dynamic(scheme: .note)
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 14
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        btn.setTitle("expression.add".localized, for: .normal)
        btn.setTitle("expression.added".localized, for: .selected)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .brand), for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(ExpressionKeyboardAddCell.tapAdd), for: .touchUpInside)
        return btn
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerCell(ExpressionKeyboardExpressionItemCell.self)
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        return view
    }()
    
}

extension ExpressionKeyboardAddCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ExpressionKeyboardExpressionItemCell.self, for: indexPath)
        let item = self.items[indexPath.row]
        cell.setItem(item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.collectionView.deselectItem(at: indexPath, animated: true)
        guard let z = self.zip else {return}
        self.singleTapListener?(z)
    }
}


class ExpressionKeyboardExpressionItemCell: UICollectionViewCell {
    
    var item: ExpressionItem?
    var longPressListener: ((ExpressionItem) -> Void)?
    
    deinit {
        print("ExpressionKeyboardExpressionItemCell ------ deinit")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        tgsImageView.translatesAutoresizingMaskIntoConstraints = false
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(tgsImageView)
        self.contentView.addSubview(gifImageView)
        self.createConstraints()
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(ExpressionKeyboardExpressionItemCell.longPress))
        self.contentView.addGestureRecognizer(longTap)
    }
    
    public func setItem(_ item: ExpressionItem) {
        self.item = item
        tgsImageView.clear()
        if item.url.hasSuffix("tgs"), let url = URL(string: item.url) {
            gifImageView.isHidden = true
            tgsImageView.isHidden = false
            tgsImageView.setSecretAnimation(url, CGSize(width: keyBoardTgsExpressionWidth * 2, height: keyBoardTgsExpressionWidth * 2), nil)
            return
        }
        gifImageView.isHidden = false
        tgsImageView.isHidden = true
        if item.url.hasSuffix("gif"), let url = URL(string: item.url)  {
            gifImageView.sd_setImage(with: url, completed: nil)
        } else {
            let data = SDImageCache.shared.diskImageData(forKey: item.url)
            gifImageView.animatedImage = FLAnimatedImage(animatedGIFData: data)
        }
    }
    
    @objc private func longPress(tap: UILongPressGestureRecognizer) {
        guard let i = item else {return}
        switch tap.state {
        case .began:
            longPressListener?(i)
        default:
            break
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        var constraints = [
            tgsImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            tgsImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            tgsImageView.widthAnchor.constraint(equalToConstant: keyBoardTgsExpressionWidth),
            tgsImageView.widthAnchor.constraint(equalToConstant: keyBoardTgsExpressionWidth)
        ]
        constraints += [
            gifImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            gifImageView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            gifImageView.widthAnchor.constraint(equalToConstant: keyBoardGifExpressionWidth),
            gifImageView.widthAnchor.constraint(equalToConstant: keyBoardGifExpressionWidth)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var tgsImageView: StickerAnimatedImageView = {
        let imageview = StickerAnimatedImageView(frame: .zero)
        imageview.contentMode = .scaleAspectFit
        imageview.isUserInteractionEnabled = true
        return imageview
    }()
    
    private lazy var gifImageView: FLAnimatedImageView = {
        let imageview = FLAnimatedImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.isUserInteractionEnabled = true
        return imageview
    }()
    
}
