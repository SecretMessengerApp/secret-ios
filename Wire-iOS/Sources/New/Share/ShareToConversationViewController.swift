//
//  ShareToConversationViewController.swift
//  Wire-iOS
//

import Foundation
import Cartography

protocol ShareToConversationViewControllerDelegate: class {
    func shareTocontroller(controller: ShareToConversationViewController, didSelectUsers: Set<ZMUser>)
}

extension ShareToConversationViewController.Context {
    
    var title: String {
        let message: String
        switch self {
        case .image:
            message = "shareToConversationViewController.context.sharePicture".localized
        case .video:
            message = "shareToConversationViewController.context.shareVideo".localized
        case .groupLink:
            message = "shareToConversationViewController.context.shareGroupLink".localized
        case .groupCreatorChange:
            message = "shareToConversationViewController.context.choose_new_owner".localized
        }
        return message
    }
    
    var selectionLimit: Int {
        return 4
    }
    
    var alertForSelectionOverflow: UIAlertController {
        let max = self.selectionLimit
        let message: String
        switch self {
        case .image:
            message = "add_participants.alert.message.new_conversation".localized(args: max)
        case .video:
            message = "shareToConversationViewController.context.shareVideo".localized
        case .groupLink:
            message = "shareToConversationViewController.context.shareGroupLink".localized
        case .groupCreatorChange:
            message = "shareToConversationViewController.context.choose_new_owner".localized
        }
        
        let controller = UIAlertController(
            title: "add_participants.alert.title".localized,
            message: message,
            preferredStyle: .alert
        )
        
        controller.addAction(.ok())
        return controller
    }
    
    var participantsWay: SearchResultsViewControllerParticipantsWay {
        switch self {
        case .groupCreatorChange:
            return SearchResultsViewControllerParticipantsWay.changeCreator
        default:
            return SearchResultsViewControllerParticipantsWay.share
        }
    }
}


class ShareToConversationViewController: UIViewController {
    
    public enum Context {
        case image(Data)
        case video(String)
        case groupLink(String)
        case groupCreatorChange
    }
    fileprivate weak var delegate: ShareToConversationViewControllerDelegate?
    fileprivate let context: Context
    fileprivate let variant: ColorSchemeVariant
    fileprivate let searchResultsViewController: SearchResultsViewController
    fileprivate let searchHeaderViewController: SearchHeaderViewController
    var userSelection: UserSelection = UserSelection()
    fileprivate let collectionView: UICollectionView
    fileprivate let collectionViewLayout: UICollectionViewFlowLayout
    fileprivate let confirmButtonHeight: CGFloat = 46.0
    fileprivate let confirmButton: IconButton
    fileprivate let emptyResultView: EmptySearchResultsView
    fileprivate var bottomConstraint: NSLayoutConstraint?
    fileprivate let backButtonDescriptor = BackButtonDescription()
    private let bottomMargin: CGFloat = UIScreen.hasBottomInset ? 8 : 16
    
    deinit {
        userSelection.remove(observer: self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchHeaderViewController.tokenField.resignFirstResponder()
    }
    
    public init(context: Context,
                variant: ColorSchemeVariant = ColorScheme.default.variant,
                userselection: UserSelection? = nil,
                conversation: ZMConversation? = nil,
                delegate: ShareToConversationViewControllerDelegate? = nil) {
        self.variant = variant
        self.context = context
        
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumInteritemSpacing = 12
        collectionViewLayout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.allowsMultipleSelection = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        confirmButton = IconButton()
        confirmButton.setIconColor(UIColor.from(scheme: .iconNormal, variant: .dark), for: .normal)
        confirmButton.setIconColor(UIColor.from(scheme: .iconHighlighted, variant: .dark), for: .highlighted)
        confirmButton.setTitleColor(UIColor.from(scheme: .iconNormal, variant: .dark), for: .normal)
        confirmButton.setTitleColor(UIColor.from(scheme: .iconHighlighted, variant: .dark), for: .highlighted)
        confirmButton.titleLabel?.font = FontSpec(.small, .medium).font!
        confirmButton.backgroundColor = UIColor.accent()
        confirmButton.contentHorizontalAlignment = .center
        confirmButton.setTitleImageSpacing(16, horizontalMargin: 24)
        confirmButton.hasRoundCorners = true
        
        if let u = userselection {
            self.userSelection = u
        }
        
        searchHeaderViewController = SearchHeaderViewController(userSelection: self.userSelection)
        searchResultsViewController = SearchResultsViewController(userSelection: self.userSelection,
                                                                  participantsWay: context.participantsWay,
                                                                  shouldIncludeGuests: false)
        searchResultsViewController.filterConversation = conversation
        emptyResultView = EmptySearchResultsView(variant: self.variant, isSelfUserAdmin: ZMUser.selfUser().canManageTeam)
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        
        updateTitle()
        
        confirmButton.addTarget(self, action: #selector(didConfirmAction), for: .touchUpInside)
        confirmButton.setTitle("url_action.confirm".localized, for: .normal)
        
        searchResultsViewController.mode = .list
        searchResultsViewController.searchForContractAndConversation(withQuery: "")

        self.userSelection.add(observer: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        searchHeaderViewController.delegate = self
        addChild(searchHeaderViewController)
        view.addSubview(searchHeaderViewController.view)
        searchHeaderViewController.didMove(toParent: self)
        
        addChild(searchResultsViewController)
        view.addSubview(searchResultsViewController.view)
        searchResultsViewController.didMove(toParent: self)
        searchResultsViewController.searchResultsView?.emptyResultView = emptyResultView
        searchResultsViewController.searchResultsView?.backgroundColor = UIColor.from(scheme: .contentBackground, variant: self.variant)
 
        view.backgroundColor = UIColor.from(scheme: .contentBackground, variant: self.variant)
        view.addSubview(confirmButton)
        
        createConstraints()
        updateSelectionValues()
        
        if searchResultsViewController.isResultEmpty {
            emptyResultView.updateStatus(searchingForServices: false, hasFilter: false)
        }
    }
    
    func createConstraints() {
        let margin = (searchResultsViewController.view as! SearchResultsView).accessoryViewMargin
        
        constrain(view, searchHeaderViewController.view,
                  searchResultsViewController.view,
                  confirmButton) { container, searchHeaderView, searchResultsView, confirmButton in
            
            searchHeaderView.top == container.top
            searchHeaderView.left == container.left
            searchHeaderView.right == container.right
            
            searchResultsView.left == container.left
            searchResultsView.right == container.right
            searchResultsView.bottom == container.bottom
            
            confirmButton.height == self.confirmButtonHeight
            confirmButton.left == container.left + margin
            confirmButton.right == container.right - margin
            
            self.bottomConstraint = confirmButton.bottom == container.safeAreaLayoutGuideOrFallback.bottom - bottomMargin
        }
        
        constrain(searchHeaderViewController.view,
                  searchResultsViewController.view) { searchHeaderView, searchResultsView in
            searchResultsView.top == searchHeaderView.bottom
        }

    }
    
    fileprivate func updateSelectionValues() {
        // Update confirm button visibility & collection view content inset
        confirmButton.isHidden = userSelection.users.isEmpty
        let bottomInset = confirmButton.isHidden ? bottomMargin : confirmButtonHeight + 16 + bottomMargin
        searchResultsViewController.searchResultsView?.collectionView.contentInset.bottom = bottomInset
        
        updateTitle()
    }
    
    private func updateTitle() {
        title = {
            self.context.title + "(\(userSelection.users.count))"
        }()
        let item = UIBarButtonItem.init(icon: StyleKitIcon.cross, target: self, action: #selector(rightNavigationItemTapped))
        item.accessibilityIdentifier = "close"
        navigationItem.rightBarButtonItem = item
    }
    
    @objc private func rightNavigationItemTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardFrameWillChange(notification: Notification) {
        // Don't adjust the frame when being presented in a popover.
        if let arrowDirection = popoverPresentationController?.arrowDirection, arrowDirection == .unknown {
            return
        }
        
        let firstResponder = UIResponder.currentFirst
        let inputAccessoryHeight = firstResponder?.inputAccessoryView?.bounds.size.height ?? 0
        
        UIView.animate(withKeyboardNotification: notification, in: self.view, animations: { (keyboardFrameInView) in
            let keyboardHeight = keyboardFrameInView.size.height - inputAccessoryHeight
            let margin: CGFloat = {
                guard UIScreen.hasNotch, keyboardHeight > 0 else { return self.bottomMargin }
                return -self.bottomMargin
            }()
            
            self.bottomConstraint?.constant = -(keyboardHeight + margin)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func performSearch() {
        let hasFilter = !searchHeaderViewController.tokenField.filterText.isEmpty
        emptyResultView.updateStatus(searchingForServices: false, hasFilter: hasFilter)
        
        searchResultsViewController.mode = .search
        searchResultsViewController.searchForContractAndConversation(withQuery: searchHeaderViewController.tokenField.filterText)
    }
    
    @objc fileprivate func didConfirmAction() {
        switch self.context {
        case .image(let data):
            for user in self.userSelection.users {
                user.connection?.conversation.append(imageFromData: data)
            }
        case .video(let videoPath):
            for user in self.userSelection.users {
                FileMetaDataGenerator.metadataForFileAtURL(URL(fileURLWithPath: videoPath), UTI: videoPath, name: videoPath) { (metaData) in
                    ZMUserSession.shared()?.performChanges {
                        user.connection?.conversation.append(file: metaData)
                    }
                }
            }
        case .groupLink:
//            for user in self.userSelection.users {
//                user.connection?.conversation.append(text: grouplink)
//            }
            break
        case .groupCreatorChange:
           self.delegate?.shareTocontroller(controller: self, didSelectUsers: self.userSelection.users)
        }
        self.rightNavigationItemTapped()
    }
}

extension ShareToConversationViewController: UserSelectionObserver {
    
    public func userSelection(_ userSelection: UserSelection, didAddUser user: ZMUser) {
        updateSelectionValues()
    }
    
    public func userSelection(_ userSelection: UserSelection, didRemoveUser user: ZMUser) {
        updateSelectionValues()
    }
    
    public func userSelection(_ userSelection: UserSelection, wasReplacedBy users: [ZMUser]) {
        updateSelectionValues()
    }
    
}

extension ShareToConversationViewController: SearchHeaderViewControllerDelegate {
    func searchHeaderViewControllerDidConfirmAction(_ searchHeaderViewController: SearchHeaderViewController) {
        
    }
    
    public func searchHeaderViewController(_ searchHeaderViewController: SearchHeaderViewController, updatedSearchQuery query: String) {
        self.performSearch()
    }
    
}

extension ShareToConversationViewController: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overFullScreen
    }
    
}
