
import UIKit
import SDWebImage

class EmojjSheetView: UIView {
    typealias EmojjPackage = ExpressionZip
    
    private var collectionView: UICollectionView!
    private let reuseIdentifier = "cell"
    private let layout = KingGridLayout(widthDimension: .auto, heightDimension: .fractionalWidth(ratio: 1.0))

    private let model: EmojjPackage
    
    public var disableSelection: Bool = false {
        didSet {
            self.collectionView.allowsSelection = !self.disableSelection
        }
    }
    
    init(model: EmojjPackage) {
        self.model = model
        super.init(frame: .zero)

        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        layout.cols = 4
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(GifCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        collectionView.secret.pin()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
    }
}

extension EmojjSheetView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GifCollectionViewCell
        let gif = model.gifs[indexPath.row].url
        cell.imageView.set(gif, size: CGSize(width: layout.itemSize.width * 2, height: layout.itemSize.height * 2))
        cell.backgroundColor = .clear

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        WRTools.shake()
        let theAttributes = collectionView.layoutAttributesForItem(at: indexPath)!
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let gif = model.gifs[indexPath.row]
        let frame = collectionView.convert(theAttributes.frame, to: window)
        let v = EmojjPreviewView(url: gif.url, contentFrame: frame, name: gif.name)
        v.show()
    }
}

class GifCollectionViewCell: UICollectionViewCell {
    let imageView = AnimatedView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubview(imageView)
        imageView.secret.pin()
    }
}

class EmojjSheet {
    typealias EmojjPackage = ExpressionZip
    
    ///
    /// - Parameters:
    ///   - content:
    ///   - vc: paretnt vc
    ///   - showAction: action
    static func show(content: EmojjPackage, in vc: UIViewController, disableSelection: Bool = false) {
        guard UIScreen.isPhone else { return }
        // Create a custom view for testing...
        let customView = EmojjSheetView(model: content)
        customView.disableSelection = disableSelection
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the alert and show it
        let alert = UIAlertController(title: content.name, message: nil, preferredStyle: .actionSheet)
        alert.view.addSubview(customView)
        alert.setBackgroundColor(color: .dynamic(scheme: .panelBackground))
        alert.setTint(color: .dynamic(scheme: .brand))
        alert.setTitle(font: FontSpec(.normal, .semibold).font, color: .dynamic(scheme: .title))
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 45).isActive = true
        customView.rightAnchor.constraint(equalTo: alert.view.rightAnchor, constant: -10).isActive = true
        customView.leftAnchor.constraint(equalTo: alert.view.leftAnchor, constant: 10).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        alert.view.heightAnchor.constraint(equalToConstant: 430).isActive = true
        
        if !content.isDefault {
            if content.hasAdded {
                alert.addAction(UIAlertAction(title: "remove_stickers.alert".localized(args: content.count), style: .destructive, handler: { _ in
                    LocalExpressionStore.zip.removeData("\(content.id)")
                    //                NotificationCenter.default.post(name: .emojjPackagesChanged, object: nil)
                    ExpressionModel.shared.postExpressionZipChanged()
                }))
            } else {
                
                alert.addAction(UIAlertAction(title: "add_stickers.alert".localized(args: content.count), style: .default, handler: { _ in
                    LocalExpressionStore.zip.addData("\(content.id)")
                    //                NotificationCenter.default.post(name: .emojjPackagesChanged, object: nil)
                    ExpressionModel.shared.postExpressionZipChanged()
                }))
            }
        }
 
        alert.addAction(UIAlertAction(title: "general.cancel".localized, style: .cancel, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
        
    }
}
