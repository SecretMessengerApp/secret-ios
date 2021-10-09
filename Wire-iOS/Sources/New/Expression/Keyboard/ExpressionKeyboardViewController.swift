
import UIKit
import SDWebImage
import WireDataModel

enum ExpressionKeyBoardType {
    case favorite
    case recent
    case expression(id: Int)
    case add
}

final class ExpressionKeyboardViewController: UIViewController {
    
    var selectIndexListener: ((Int) -> Void)?
    var refreshBarListener: (() -> Void)?
    
    var conversation: ZMConversation

    let expressionModel = ExpressionModel.shared
    var expressionZips: [ExpressionZip] = []
    var selectZip: Int = 0
    var canResponseScroll: Bool = true

    var favoriteZip: ExpressionZip?
    var recentZip: ExpressionZip?

    deinit {
        ExpressionModel.shared.removeObserver(self)
    }
    
    init(conversation: ZMConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        ExpressionModel.shared.addFavoriteExpressionChangedOberver(self, selector: #selector(favoriteExpressionChanged))
        ExpressionModel.shared.addRecentExpressionChangedOberver(self, selector: #selector(addRecentExpressionChanged))
        ExpressionModel.shared.addExpressionZipChangedOberver(self, selector: #selector(expressionZipChanged))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .dynamic(scheme: .groupBackground)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        self.createConstraints()
        self.generateDatas()
        self.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        let constraints = [
            collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc private func favoriteExpressionChanged() {
        let originFavorite = self.expressionZips.filter {
            $0.id == myFavoriteExpressionZipId
        }.first
        let orIndex = self.expressionZips.firstIndex { (zip) -> Bool in
            return zip.id == myFavoriteExpressionZipId
        }
        self.generateDatas()
        let targetFavorite = self.expressionZips.filter {$0.id == myFavoriteExpressionZipId}.first
        let opIndex = self.expressionZips.firstIndex { (zip) -> Bool in
            return zip.id == myFavoriteExpressionZipId
        }
        if originFavorite == nil && targetFavorite == nil {
            return
        }
        if originFavorite == nil && targetFavorite != nil {
            self.collectionView.insertSections(IndexSet(arrayLiteral: opIndex!))
            return
        }
        if originFavorite != nil && targetFavorite == nil {
            self.collectionView.deleteSections(IndexSet(arrayLiteral: orIndex!))
            return
        }
        self.collectionView.reloadSections(IndexSet(arrayLiteral: opIndex!))
    }
    
    func postExpressionChanged() {
        ExpressionModel.shared.postFavoriteExpressionChanged()
    }
    
    @objc private func addRecentExpressionChanged() {
        let originRecent = self.expressionZips.filter {$0.id == myRecentExpressionZipId}.first
        self.generateDatas()
        let opIndex = self.expressionZips.firstIndex { (zip) -> Bool in
            return zip.id == myRecentExpressionZipId
        }
        guard let index = opIndex else {return}
        if originRecent != nil {
            self.collectionView.reloadSections(IndexSet(arrayLiteral: index))
        } else {
            self.collectionView.insertSections(IndexSet(arrayLiteral: index))
        }
    }
    
    @objc private func expressionZipChanged() {
        self.generateDatas()
        self.reloadData()
        self.scrollToZip(0)
    }
    
    func generateDatas() {
        expressionZips.removeAll()
        self.favoriteZip = ExpressionZip(id: myFavoriteExpressionZipId, name: "Favorite", gifs: LocalExpressionStore.favorite.getAllData())
        self.recentZip = ExpressionZip(id: myRecentExpressionZipId, name: "Recent", gifs: LocalExpressionStore.recent.getAllData())
        let secretZips = ExpressionModel.shared.getSecretExpressions()
        let myFavoriteZips = ExpressionModel.shared.getMyExpressionZips()
        expressionZips = secretZips + myFavoriteZips
        if recentZip!.gifs.count > 0 {
            expressionZips.insert(recentZip!, at: 0)
        }
        if favoriteZip!.gifs.count > 0 {
            expressionZips.insert(favoriteZip!, at: 0)
        }
    }
    
    func reloadData() {
        self.collectionView.reloadData()
    }
    
    func selectZip(_ index: Int) {
        if selectZip == index {return}
        selectZip = index
        self.selectIndexListener?(selectZip)
    }
    
    func scrollToZip(_ index: Int) {
        canResponseScroll = false
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: index), at: [.top], animated: true)
        delay(0.6) {
           self.canResponseScroll = true
        }
    }
    
    func setHeaderViewListener(headerView: ExpressionCollectionHeaderView) {
        headerView.needReloadListener = { [weak self] in
            self?.generateDatas()
            self?.reloadData()
        }
    }
    
    func setCellListeners(cell: ExpressionKeyboardExpressionItemCell) {
        let rect  = self.collectionView.convert(cell.frame, to: cell.window)
        cell.longPressListener = { [weak self] item in
            guard let self = self else {return}
            WRTools.shake()
            let preView = EmojjPreviewView(url: item.url, contentFrame: rect, name: item.name)
            preView.addAction(title: "expression.send".localized, handler: { [weak self] in
                guard let self = self else {return}
                self.sendMessage(item: item, zip: item.originZip)
            })
            if item.busiZip?.isNotFavorite ?? true {
                preView.addAction(title: "expression.favorite.add".localized, handler: { [weak self] in
                    guard let self = self else {return}
                    self.addFavoriteItem(item: item)
                })
            } else {
                preView.addAction(title: "expression.favorite.remove".localized, handler: { [weak self] in
                    guard let self = self else {return}
                    self.removeFavoriteItem(item: item)
                })
            }
            if  item.originZip != nil {
                preView.addAction(title: "expression.check.album".localized, handler: { [weak self] in
                    guard let self = self else {return}
                    self.showExpressionZipPreView(item: item)
                })
            }
            preView.addAction(title: "expression.cancel".localized, handler: {})
            preView.show(window: self.view.window)
        }
    }
    
    func addFavoriteItem(item: ExpressionItem) {
        LocalExpressionStore.favorite.addData(item.url)
        self.favoriteExpressionChanged()
        self.postExpressionChanged()
    }
    
    func removeFavoriteItem(item: ExpressionItem) {
        LocalExpressionStore.favorite.removeData(item.url)
        self.favoriteExpressionChanged()
        self.postExpressionChanged()
    }
    
    func showExpressionZipPreView(item: ExpressionItem) {
        guard let zip = item.originZip else {return}
        guard let views = self.view.window?.subviews else {return}
        let vc = getInputWindowController(views: views)
        guard let v = vc else {return}
        EmojjSheet.show(content: zip, in: v, disableSelection: true)
    }
    
    func sendMessage(item: ExpressionItem, zip: ExpressionZip?) {
        if item.url.containsURL, let z = zip {
            ZMUserSession.shared()?.enqueueChanges { [weak self] in
                self?.conversation.appendExpressionMessage(url: item.url, name: item.name, zipId: "\(z.id)", zipName: "\(z.name)", zipIcon: "\(z.icon)")
            }
            return
        }
        if let data = SDImageCache.shared.diskImageData(forKey: item.url) {
            ZMUserSession.shared()?.enqueueChanges { [weak self] in
                self?.conversation.append(imageFromData: data)
            }
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        let itemWidth = UIScreen.main.bounds.width / 5
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerCell(ExpressionKeyboardExpressionItemCell.self)
        view.registerSectionHeader(ExpressionCollectionHeaderView.self)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
}

extension ExpressionKeyboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.expressionZips[section].gifs.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.expressionZips.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ExpressionKeyboardExpressionItemCell.self, for: indexPath)
        cell.setItem(self.expressionZips[indexPath.section].gifs[indexPath.row])
        self.setCellListeners(cell: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueSectionHeader(ExpressionCollectionHeaderView.self, for: indexPath)
        headerView.setZip(zip: self.expressionZips[indexPath.section])
        self.setHeaderViewListener(headerView: headerView)
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 32)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.expressionZips[indexPath.section].gifs[indexPath.row]
        self.sendMessage(item: item, zip: item.originZip)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard canResponseScroll else {return}
        let firstCell = self.collectionView.visibleCells.sorted { (cell1, cell2) -> Bool in
            return cell1.frame.origin.y < cell2.frame.origin.y
        }.first
        guard let first = firstCell else {return}
        let indexPath = self.collectionView.indexPath(for: first)
        guard let indexp = indexPath else {return}
        print("\(indexp.section)")
        self.selectZip(indexp.section)
    }

}


extension UIView {
    func getInputWindowController() -> UIViewController? {
        var aNext: UIResponder? = self.next
        while aNext != nil {
            if aNext!.isKind(of: NSClassFromString("UIInputWindowController")!) {
                return aNext as? UIViewController
            }
            aNext = aNext?.next
        }
        return nil
    }
}

func getInputWindowController(views: [UIView]) -> UIViewController? {
    for v in views {
        if let vc = v.getInputWindowController() {
            return vc
        }
    }
    return nil
}
