

import UIKit

class ConversationShortcutView: UIView {
    private var itemsPerLine = 4
    private var linesPerPage = 1
    private var maxHeightConstraint: NSLayoutConstraint!

    static var shortCutView: ConversationShortcutView? = nil
    
    public static func showOn(_ view: UIView? = nil) {
        if shortCutView != nil {
            shortCutView?.removeFromSuperview()
            shortCutView = nil
        }
        guard let account = SessionManager.shared?.accountManager.selectedAccount else { return }
        let ids = Settings.shared.shortcutConversations(for: account).ids
        if  ids.count == 1,
            let id = ids.first,
            let uuid = UUID(uuidString: id),
            let conversation = ZMConversation(remoteID: uuid) {
            open(conv: conversation)
            return
        }
        
        var v: UIView? = view
        if v == nil {
            v = UIApplication.shared.keyWindow
        }
        shortCutView?.removeFromSuperview()
        shortCutView = nil
        shortCutView = ConversationShortcutView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - UIScreen.safeArea.bottom - 49))
        v!.addSubview(shortCutView!)
        ZClientViewController.shared?.mainTabBarController?.openShortcutViewTabbarItem()
    }
    
    public static func dismiss() {
        ZClientViewController.shared?.mainTabBarController?.closeShortcutViewTabbarItem()
        if ConversationShortcutView.shortCutView == nil {
            return
        }
        ConversationShortcutView.shortCutView?.removeFromSuperview()
        ConversationShortcutView.shortCutView = nil
    }
    
    var conversations: [ZMConversation] = []
    
    var deleConversations: [ZMConversation] = []
    
    var pushedIDs = [String]()
    
    var isEdit: Bool = false
    
    private var currentLongPressIndexPath: IndexPath? {
        didSet {
            guard let current = currentLongPressIndexPath,
                  current != oldValue else { return }
            if oldValue != nil {
                guard let oldCell = collectionView.cellForItem(at: oldValue! ) as? ConversationShortcutCollectionCell else { return }
                guard let newCell = collectionView.cellForItem(at: current ) as? ConversationShortcutCollectionCell else { return }
                oldCell.headerImgView.clippingView.layer.borderWidth = 0
                oldCell.headerImgView.clippingView.layer.borderColor = UIColor.init(hex: "#76C3FF").cgColor
                newCell.headerImgView.clippingView.layer.borderWidth = 1.5
                newCell.headerImgView.clippingView.layer.borderColor = UIColor.init(hex: "#76C3FF").cgColor
            } else {
                if let newCell = collectionView.cellForItem(at: current ) as? ConversationShortcutCollectionCell {
                    newCell.headerImgView.clippingView.layer.borderWidth = 1.5
                    newCell.headerImgView.clippingView.layer.borderColor = UIColor.init(hex: "#76C3FF").cgColor
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(visualEffectView)
        visualEffectView.addSubview(self.gestureView)
        visualEffectView.addSubview(self.contentView)
        visualEffectView.addSubview(self.contentShapeImageView)
        self.contentView.addSubview(self.collectionView)
//        self.contentView.addSubview(self.editButton)
        self.contentView.addSubview(self.doneButton)
        self.contentView.addSubview(self.pageView)
        self.doneButton.isHidden = true
        
        [self.containerView,
         visualEffectView,
         self.gestureView,
         self.contentView,
         self.editButton,
         self.collectionView,
         self.contentShapeImageView,
         self.doneButton,
         self.pageView].forEach { $0.translatesAutoresizingMaskIntoConstraints = false
        }
        self.createConstraints()
        self.loadData()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toucharound))
        gestureView.addGestureRecognizer(gesture)
        
        setupMenu()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createConstraints() {
        self.maxHeightConstraint = self.contentView.heightAnchor.constraint(equalToConstant: 145)
        
        var constraints = [
            visualEffectView.leftAnchor.constraint(equalTo: self.leftAnchor),
            visualEffectView.rightAnchor.constraint(equalTo: self.rightAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            visualEffectView.topAnchor.constraint(equalTo: self.topAnchor)
        ]

        constraints += [
            self.contentView.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor, constant: 8),
            self.contentView.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor, constant: -8),
            self.contentView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -24),
            maxHeightConstraint
        ]
        
        constraints += [
            self.contentShapeImageView.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
            self.contentShapeImageView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            self.contentShapeImageView.widthAnchor.constraint(equalToConstant: 24),
            self.contentShapeImageView.heightAnchor.constraint(equalToConstant: 12)
        ]
        
        constraints += [
            self.gestureView.topAnchor.constraint(equalTo: visualEffectView.topAnchor),
            self.gestureView.leftAnchor.constraint(equalTo: visualEffectView.leftAnchor, constant: 8),
            self.gestureView.rightAnchor.constraint(equalTo: visualEffectView.rightAnchor, constant: -8),
            self.gestureView.bottomAnchor.constraint(equalTo: contentView.topAnchor)
        ]
        
//        constraints += [
//            self.editButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -12),
//            self.editButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
//            self.editButton.widthAnchor.constraint(equalToConstant: 25),
//            self.editButton.heightAnchor.constraint(equalToConstant: 25)
//        ]
        
        constraints += [
            self.doneButton.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -12),
            self.doneButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
            self.doneButton.widthAnchor.constraint(equalToConstant: 40),
            self.doneButton.heightAnchor.constraint(equalToConstant: 17)
        ]
        constraints += [
            self.collectionView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 30),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -30)
        ]
        constraints += [
            self.pageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.pageView.topAnchor.constraint(equalTo: self.collectionView.bottomAnchor, constant: 4),
            self.pageView.widthAnchor.constraint(equalToConstant: 120),
            self.pageView.heightAnchor.constraint(equalToConstant: 15)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func loadData() {
        if let account = SessionManager.shared?.accountManager.selectedAccount {
            let (ids, pushedIDs) = Settings.shared.shortcutConversations(for: account)
            self.pushedIDs = pushedIDs
            self.conversations = ids.compactMap { id in
                if let uuid = UUID(uuidString: id) {
                    return ZMConversation(remoteID: uuid)
                }
                return nil
            }
        }

        self.reloadData()
    }
    
    @objc func edit() {
        WRTools.shake()
        self.isEdit = true
        self.doneButton.isHidden = false
        self.editButton.isHidden = true
        self.reloadData()
    }
    
    @objc func done() {
        WRTools.shake()
        self.isEdit = false
        self.doneButton.isHidden = true
        self.editButton.isHidden = false
        guard let account = SessionManager.shared?.accountManager.selectedAccount else {return}
        deleConversations.forEach { Settings.shared.removeShortcurConversation($0, for: account)
        }
        deleConversations.removeAll()
        self.reloadData()
    }
    
    func reloadData() {
        self.linesPerPage = self.conversations.count > itemsPerLine ? 2 : 1
        self.maxHeightConstraint.constant = (self.conversations.count > itemsPerLine && linesPerPage > 1) ? 270 : 155
        self.layout.rows = self.linesPerPage
        self.layoutIfNeeded()
        
        let page = ceil(lhs: self.conversations.count, rhs: linesPerPage * itemsPerLine)
        self.pageView.numberOfPages = page
        self.pageView.currentPage = 0
        let ishidden = self.conversations.count <= linesPerPage * itemsPerLine
        self.pageView.isHidden = ishidden
        self.collectionView.reloadData()
    }
    
    @objc func toucharound() {
        WRTools.shake()
        ZClientViewController.shared?.mainTabBarController?.setShortcutTabBarItem()
        ConversationShortcutView.dismiss()
    }
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var gestureView: UIView = {
       let view = UIView()
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.dynamic(scheme: .panelBackground)
        view.layer.cornerRadius = 13
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var contentShapeImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.init(named: "shortcut_shape")?.withColor(UIColor.dynamic(scheme: .panelBackground))
        return view
    }()
    
    lazy var pageView: UIPageControl = {
        let view = UIPageControl()
        view.hidesForSinglePage = true
        if #available(iOS 14.0, *) {
            view.backgroundStyle = .minimal
        } else {
            // Fallback on earlier versions
        }
        view.pageIndicatorTintColor = UIColor.dynamic(scheme: .separator)
        view.currentPageIndicatorTintColor = .black
        return view
    }()
    
    lazy var editButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "shortcut_edit"), for: .normal)
        btn.addTarget(self, action: #selector(ConversationShortcutView.edit), for: .touchUpInside)
        return btn
    }()
    
    lazy var doneButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("global.action.done".localized, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
        btn.addTarget(self, action: #selector(ConversationShortcutView.done), for: .touchUpInside)
        return btn
    }()
    
    let layout = GridLayout()
    
    lazy var collectionView: UICollectionView = {

        layout.columns = 4
        layout.rows = 1
        layout.cellSpacing = 20
        
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        view.isPagingEnabled = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.registerCell(ConversationShortcutCollectionCell.self)
        view.registerCell(UICollectionViewCell.self)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    lazy var visualEffectView: UIImageView = {
        let imageView = UIImageView()
        let orignalImage = UIApplication.shared.keyWindow?.snapshot()
        let image = orignalImage?.applyBlur(
            radius: 6,
            tintColor: UIColor(white: 0.11, alpha: 0.22),
            saturationDeltaFactor: 1.8,
            maskImage: nil
        )
        imageView.image = image
        imageView.contentMode = .top
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    func setupMenu() {
        let deleteItem = createMenuItem(title: "Delete".localizedCapitalized, action: #selector(menuDeleteHandler(_:)))
        let shareItem = createMenuItem(title: "Share".localizedCapitalized, action: #selector(menuShareHandler(_:)))
        
        let menu = UIMenuController.shared
        menu.menuItems = [shareItem, deleteItem]
        menu.update()
    }
    
    func createMenuItem(title: String, action: Selector) -> UIMenuItem {
        return UIMenuItem(title: title, action: action)
    }
    
    @objc func menuDeleteHandler(_ sender: Any) { }
    
    @objc func menuShareHandler(_ sender: Any) { }
    
    func shouldShowRedPoint(for conversation: ZMConversation) -> Bool {
        guard let id = conversation.remoteIdentifier?.transportString() else { return false }
        if !pushedIDs.contains(id) {
            return false
        }
        
        return !Settings.shared.hasClicked(conversation)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        contentShapeImageView.image = UIImage.init(named: "shortcut_shape")?.withColor(UIColor.dynamic(scheme: .panelBackground))
    }
}

extension ConversationShortcutView: UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let conversation = self.conversations[indexPath.row]
        let cell = collectionView.dequeueCell(ConversationShortcutCollectionCell.self, for: indexPath)
        
        
//        cell.headerImgView.userImageView.addTarget(self, action: #selector(userHeaderImgTap), for: .touchUpInside)
        
        if let url = conversation.fifth_image {
            cell.headerImgView.configure(context: .custom(url: url))
            cell.nameLabel.text = conversation.fifth_name
        } else {
            cell.headerImgView.configure(context: .conversation(conversation: conversation))
            cell.nameLabel.text = conversation.displayName
        }
        cell.editImgView.isHidden = !self.isEdit
        cell.headerImgView.isUserInteractionEnabled = false
        cell.hasRedPoint = shouldShowRedPoint(for: conversation)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let conversation = self.conversations[indexPath.row]
        WRTools.shake()
        
        Settings.shared.markClicked(conversation)
        collectionView.reloadItems(at: [indexPath])

        self.selectConversation(conversation: conversation)
    }
    
    @objc func userHeaderImgTap(view: ConversationAvatarView) {
        WRTools.shake()
        let cell = view.superview?.superview?.superview?.superview as! ConversationShortcutCollectionCell
        let indexPath = self.collectionView.indexPath(for: cell)
        guard let index = indexPath else {return}
        let conversation = self.conversations[index.row]
        
        Settings.shared.markClicked(conversation)
//        collectionView.reloadItems(at: [indexPath])
        
        
        if !self.isEdit {
            self.selectConversation(conversation: conversation)
            ConversationShortcutView.dismiss()
        } else {
            self.removeConversation(conversation: conversation)
        }
    }
    
    private func selectConversation(conversation: ZMConversation) {
        type(of: self).open(conv: conversation)
    }
    
    static func open(conv: ZMConversation) {
        if  conv.conversationType == .invalid  {
            ConversationShortcutView.dismiss()
            JoinConversationManager(inviteURLString: conv.joinGroupUrl ?? "").checkOrPresentJoinAlert(on: MainTabBarController.shared!)
            return
        }
        
        ConversationShortcutView.dismiss()
        ZClientViewController.shared?.mainTabBarController?.selectedIndex = 0
        MainTabBarController.shared?.wr_splitViewController?.setRightFullscreen(false)
        ZClientViewController.shared?.select(conversation: conv, focusOnView: true, animated: true)
    }
    
    private func removeConversation(conversation: ZMConversation) {
        if let index = self.conversations.firstIndex(where: { (conv) -> Bool in
            return conv.remoteIdentifier?.transportString() == conversation.remoteIdentifier?.transportString()
        }) {
            self.conversations.remove(at: index)
            deleConversations.append(conversation)
            self.reloadData()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == 0 {
            self.pageView.currentPage = 0
        } else {
            let offset = scrollView.contentOffset.x
            let width = scrollView.frame.size.width
            let page = Int(offset / width)
            self.pageView.currentPage = page
        }
    }
    
    // MARK: Menu
    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if action == #selector(menuDeleteHandler(_:)) {
            currentLongPressIndexPath = indexPath
            return true
        }
        
        guard let convID = conversations[indexPath.row].remoteIdentifier?.transportString() else { return false }
        let isPushed = pushedIDs.contains(convID)
        if action == #selector(menuShareHandler(_:)) && isPushed {
            currentLongPressIndexPath = indexPath
            return true
        }
        
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("action")
    }
}


class ConversationShortcutCollectionCell: UICollectionViewCell {
    weak var delegate: ShortcutCellDelegate?
    
    var hasRedPoint = false {
        didSet {
            self.pointView.isHidden = !self.hasRedPoint
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.headerImgView)
        self.contentView.addSubview(self.nameLabel)
//        self.contentView.addSubview(self.editImgView)
        self.contentView.addSubview(self.pointView)
        [self.headerImgView, self.nameLabel, self.pointView].forEach {$0.translatesAutoresizingMaskIntoConstraints = false}
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createConstraints() {
        NSLayoutConstraint.activate([
            self.headerImgView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.headerImgView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            self.headerImgView.widthAnchor.constraint(equalToConstant: 52),
            self.headerImgView.heightAnchor.constraint(equalToConstant: 52),
            self.nameLabel.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.nameLabel.topAnchor.constraint(equalTo: self.headerImgView.bottomAnchor, constant: 15),
            self.nameLabel.widthAnchor.constraint(equalToConstant: 62),
//            self.nameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16),
            
//            self.editImgView.topAnchor.constraint(equalTo: headerImgView.topAnchor),
//            self.editImgView.rightAnchor.constraint(equalTo: headerImgView.rightAnchor),
            
            self.editImgView.widthAnchor.constraint(equalToConstant: 18),
            self.editImgView.heightAnchor.constraint(equalToConstant: 18),
            
            self.pointView.heightAnchor.constraint(equalToConstant: 6),
            self.pointView.widthAnchor.constraint(equalToConstant: 6),
            self.pointView.topAnchor.constraint(equalTo: self.headerImgView.topAnchor),
            self.pointView.rightAnchor.constraint(equalTo: self.headerImgView.rightAnchor)
            
        ])
    }
    
    lazy var headerImgView: ConversationAvatarView = {
        let imageview = ConversationAvatarView()
//        imageview.isUserInteractionEnabled = true
        imageview.layer.cornerRadius = 52 / 2.0
        imageview.layer.masksToBounds = true
        return imageview
    }()
    
    lazy var editImgView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage.init(named: "action_normal_del")
        return imageview
    }()
    
    lazy var pointView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: 0xFD0100)
        v.cornerRadius = 3
        return v
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = FontSpec(.small, .medium).font
        label.numberOfLines = 2
        label.textColor = UIColor.dynamic(scheme: .subtitle)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    @objc func menuDeleteHandler(_ sender: Any) {
//        print("Copy")
        delegate?.menuDeleteClicked(in: self)
    }
    
    @objc func menuShareHandler(_ sender: Any) {
//        print("Share")
        delegate?.menuShareClicked(in: self)
    }
}

protocol ShortcutCellDelegate: class {
    func menuDeleteClicked(in cell: ConversationShortcutCollectionCell)
    func menuShareClicked(in cell: ConversationShortcutCollectionCell)
}

extension ConversationShortcutView: ShortcutCellDelegate {
    typealias Cell = ConversationShortcutCollectionCell
    
    func menuShareClicked(in cell: Cell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            print("Select share at \(indexPath.row)")
            let conv = self.conversations[indexPath.row]
            shareConversation(conv: conv)
        }
    }
    
    func menuDeleteClicked(in cell: Cell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            print("Select delete at \(indexPath.row)")
            let conv = self.conversations[indexPath.row]
            removeConversation(conv: conv)
            self.conversations.remove(at: indexPath.row)
            reloadData()
        }
    }
    
    func removeConversation(conv: ZMConversation) {
        guard let account = SessionManager.shared?.accountManager.selectedAccount else { return }
        Settings.shared.removeShortcurConversation(conv, for: account)
    }
    
    func shareConversation(conv: ZMConversation) {
        self.removeFromSuperview()
        guard let url = conv.joinGroupUrl else { return }
        let vc = GroupUrlShareViewController(conversation: conv, shareUrl: url, contacts: [])
        MainTabBarController.shared?.present(vc, animated: true, completion: nil)
    }
}
