//
//  GroupViewController.swift
//  Wire-iOS
//

import UIKit
import Cartography

class GroupUrlShareViewController: UIViewController, CardPresentationControllerAdapter {
    
    // MARK: - CardPresentationControllerAdapter
    var cardViewController: UIViewController {
        return self
    }
    
    var insets: UIEdgeInsets {
        return UIEdgeInsets(top: view.bounds.height - contentHeight - UIScreen.safeArea.bottom, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - View
    private var contentHeight: CGFloat {
        return 50 + collectionViewHeight + 1 + 50 + 10 + 50
    }
    
    private var collectionViewHeight: CGFloat {
        return CGFloat(collectionViewRows * (70 + 15))
    }
    
    private var collectionViewRows: Int {
        let countOfRow = Int(view.frame.width - 30 + 15) / (50 + 15)
        let itemCount = dataSource.count
        switch itemCount {
        case ...countOfRow: return 1
        case countOfRow...countOfRow * 2: return 2
        default: return 3
        }
    }
    

    // MARK: - Init
    ///
    /// - Parameter shareUrl:
    /// - Parameter contacts:
    init(conversation: ZMConversation, shareUrl: String, contacts: [ZMUser]) {
        self.conversation = conversation
        self.shareUrl = shareUrl
        self.dataSource = contacts
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.hide()
        view.backgroundColor = .dynamic(scheme: .secondaryBackground)
        userSelectionAddObserver()
        configCollectionView()
        addViewsAndConstrains()
    }
    
    deinit {
        userSelectionRemoveObserver()
    }
    
    private var conversation: ZMConversation
    private var shareUrl: String
    private var userSelection = UserSelection()
    private var dataSource: [ZMUser] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: UI Properties
    private var collectionView: UICollectionView!

    private lazy var searchBtn: IconButton = {
        let btn = IconButton()
        btn.setIcon(.search, size: .tiny, for: .normal)
        return btn
    }()

    private lazy var header: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .background)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "conversation.setting.to.group.urlshare".localized
        label.textColor = .dynamic(scheme: .title)
        label.font = UIFont(16, .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var descTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "conversation.setting.to.group.urlsubtitle".localized
        label.textAlignment = .center
        label.textColor = .dynamic(scheme: .subtitle)
        label.font = UIFont(11, .bold)
        return label
    }()

    private lazy var copyLinkBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .dynamic(scheme: .background)
        btn.setTitleColor(.dynamic(scheme: .title), for: .normal)
        btn.setTitle("guest_room.actions.copy_link".localized, for: .normal)
        btn.titleLabel?.font = UIFont(16, .bold)
        return btn
    }()

    private lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.dynamic(scheme: .title), for: .normal)
        btn.backgroundColor = .dynamic(scheme: .background)
        btn.setTitle("general.cancel".localized, for: .normal)
        btn.titleLabel?.font = UIFont(16, .bold)
        return btn
    }()
}

// MARK: - UICollectionViewDataSource / UICollectionViewDelegate
extension GroupUrlShareViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return dataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(GroupUrlShareCollectionCell.self, for: indexPath)
        let item = dataSource[indexPath.item]
        cell.configUser(with: item, conversation: conversation)
        cell.isSelected = userSelection.users.contains(item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selected = dataSource[indexPath.item]
        if userSelection.users.contains(selected) {
            userSelection.remove(selected)
        } else {
            userSelection.add(selected)
        }
    }
}


// MARK: - UserSelectionObserver
extension GroupUrlShareViewController: UserSelectionObserver {
    
    private func userSelectionAddObserver() {
        userSelection.add(observer: self)
    }
    
    private func userSelectionRemoveObserver() {
        userSelection.remove(observer: self)
    }
    
    private func updateViewState(_ userSelection: UserSelection) {
        let title = userSelection.users.isEmpty
            ? "guest_room.actions.copy_link".localized
            : "giphy.confirm".localized.capitalized + "(\(userSelection.users.count))"
        copyLinkBtn.setTitle(title, for: .normal)
        collectionView.reloadData()
    }
    
    func userSelection(_ userSelection: UserSelection, didAddUser user: ZMUser) {
        updateViewState(userSelection)
    }
    
    func userSelection(_ userSelection: UserSelection, didRemoveUser user: ZMUser) {
        updateViewState(userSelection)
    }
    
    func userSelection(_ userSelection: UserSelection, wasReplacedBy users: [ZMUser]) {
        updateViewState(userSelection)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension GroupUrlShareViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(adapter: presented as! CardPresentationControllerAdapter, presenting: presenting)
    }
}


// MARK: - Views / Constrains / Btn Actions
extension GroupUrlShareViewController {
    
    @objc private func searchBtnClicked() {
        let shareVC = ShareToConversationViewController(
            context: .groupLink(shareUrl),
            userselection: userSelection,
            conversation: conversation
        )
        present(shareVC.wrapInNavigationController(), animated: true, completion: nil)
    }
    
    @objc private func cancelBtnClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func copyLinkBtnClicked() {
        if userSelection.users.isEmpty {
            UIPasteboard.general.string = shareUrl
            dismiss(animated: true) { HUD.success("hud.copied".localized) }
        } else {
            userSelection.users.forEach { user in
                user.connection?.conversation.append(text: shareUrl)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func configCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.itemSize = CGSize(width: 50, height: 70)
        layout.minimumLineSpacing = 15
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerCell(GroupUrlShareCollectionCell.self)
        collectionView.backgroundColor = .dynamic(scheme: .background)
    }
    
    private func addViewsAndConstrains() {
        searchBtn.addTarget(self, action: #selector(searchBtnClicked), for: .touchUpInside)
        copyLinkBtn.addTarget(self, action: #selector(copyLinkBtnClicked), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
        [searchBtn, titleLabel, descTitleLabel].forEach(header.addSubview)
        [header,
         collectionView,
         copyLinkBtn,
         cancelBtn].forEach(view.addSubview)
        
        constrain(searchBtn, titleLabel, descTitleLabel, header) { search, title, desc, header in
            search.left == header.left + 15
            search.centerY == header.centerY
            
            title.centerX == header.centerX
            title.bottom == header.centerY
            
            desc.centerX == header.centerX
            desc.top == header.centerY
        }
        
        constrain(header, collectionView, copyLinkBtn, cancelBtn, view) { header, cv, link, cancel, view in
            header.left == view.left
            header.right == view.right
            header.top == view.top
            header.height == 50
            
            cv.left == view.left
            cv.right == view.right
            cv.top == header.bottom
            cv.height == collectionViewHeight
            
            link.left == view.left
            link.right == view.right
            link.top == cv.bottom + 1
            link.height == 50
            
            cancel.left == view.left
            cancel.right == view.right
            cancel.top == link.bottom + 10
            cancel.height == 50
        }
    }
}
