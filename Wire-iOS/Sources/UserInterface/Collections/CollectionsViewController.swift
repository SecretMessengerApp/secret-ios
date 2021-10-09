

import Foundation
import Cartography
import WireDataModel

protocol CollectionsViewControllerDelegate: class {
    func collectionsViewController(_ viewController: UIViewController, performAction: MessageAction, onMessage: ZMConversationMessage)
}

 final class CollectionsViewController: UIViewController {
    var onDismiss: ((CollectionsViewController)->())?
    let sections: CollectionsSectionSet
    weak var delegate: CollectionsViewControllerDelegate?
    var isShowingSearchResults: Bool {
        guard let textSearchController = self.textSearchController,
              let resultsView = textSearchController.resultsView else {
            return false
        }
        return !resultsView.isHidden
    }

    var shouldTrackOnNextOpen = false
    
    var currentTextSearchQuery: [String] {
        guard let textSearchController = self.textSearchController else {
            return []
        }
        
        return textSearchController.searchQuery?.components(separatedBy: .whitespacesAndNewlines) ?? []
    }
    
    fileprivate var contentView: CollectionsView! {
        return self.view as? CollectionsView
    }
    fileprivate let messagePresenter = MessagePresenter()
    fileprivate weak var selectedMessage: ZMConversationMessage? = .none
    
    fileprivate var imageMessages: [ZMConversationMessage] = []
    fileprivate var videoMessages: [ZMConversationMessage] = []
    fileprivate var linkMessages: [ZMConversationMessage] = []
    fileprivate var fileAndAudioMessages: [ZMConversationMessage] = []
    
    fileprivate var collection: AssetCollectionWrapper!

    fileprivate var lastLayoutSize: CGSize = .zero
    fileprivate var deletionDialogPresenter: DeletionDialogPresenter?
    
    fileprivate var fetchingDone: Bool = false {
        didSet {
            if self.isViewLoaded {
                self.updateNoElementsState()
                self.contentView.collectionView.reloadData()
            }
            
            trackOpeningIfNeeded()
        }
    }
    
    fileprivate var inOverviewMode: Bool {
        return self.sections == .all
    }
    
    fileprivate var textSearchController: TextSearchViewController!
    
    convenience init(conversation: ZMConversation) {
        let matchImages = CategoryMatch(including: .image, excluding: .GIF)
        let matchFiles = CategoryMatch(including: .file, excluding: .video)
        let matchVideo = CategoryMatch(including: .video, excluding: .none)
        let matchLink = CategoryMatch(including: .linkPreview, excluding: .none)
        
        let holder = AssetCollectionWrapper(conversation: conversation, matchingCategories: [matchImages, matchFiles, matchVideo, matchLink])
        
        self.init(collection: holder)
    }
    
    init(collection: AssetCollectionWrapper, sections: CollectionsSectionSet = .all, messages: [ZMConversationMessage] = [], fetchingDone: Bool = false) {
        self.collection = collection
        self.sections = sections
        
        switch(sections) {
        case CollectionsSectionSet.images:
            self.imageMessages = messages
        case CollectionsSectionSet.filesAndAudio:
            self.fileAndAudioMessages = messages
        case CollectionsSectionSet.videos:
            self.videoMessages = messages
        case CollectionsSectionSet.links:
            self.linkMessages = messages
        default: break
        }
        
        self.fetchingDone = fetchingDone
        
        super.init(nibName: .none, bundle: .none)
        self.collection.assetCollectionDelegate.add(self)
        self.deletionDialogPresenter = DeletionDialogPresenter(sourceViewController: self)
    }
    
    deinit {
        self.collection.assetCollectionDelegate.remove(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refetchCollection() {
        self.collection.assetCollectionDelegate.remove(self)
        self.imageMessages = []
        self.videoMessages = []
        self.linkMessages = []
        self.fileAndAudioMessages = []
        self.collection = AssetCollectionWrapper(conversation: self.collection.conversation, matchingCategories: self.collection.matchingCategories)
        self.collection.assetCollectionDelegate.add(self)
        self.contentView.collectionView.reloadData()
    }
    
    override func loadView() {
        self.view = CollectionsView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textSearchController = TextSearchViewController(conversation: self.collection.conversation)
        self.textSearchController.delegate = self
        self.contentView.constrainViews(searchViewController: self.textSearchController)
        
        self.messagePresenter.targetViewController = self
        self.messagePresenter.modalTargetController = self

        self.contentView.collectionView.delegate = self
        self.contentView.collectionView.dataSource = self
        self.contentView.collectionView.prefetchDataSource = self
        
        self.updateNoElementsState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationItem()
        self.flushLayout()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.textSearchController.teardown()
    }


    // MARK:- device orientation


    /// Notice: for iPad with iOS9 in landscape mode, horizontalSizeClass is .unspecified (.regular in iOS11).
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return wr_supportedInterfaceOrientations
    }
    
    override var shouldAutorotate: Bool {
        switch (self.traitCollection.horizontalSizeClass) {
        case .compact:
            return false
        default:
            return true
        }
    }

    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
    }

    private func flushLayout() {
        for cell in self.contentView.collectionView.visibleCells {
            guard let cell = cell as? CollectionCell else {
                continue
            }
            
            cell.flushCachedSize()
        }
        
        self.contentView.collectionViewLayout.invalidateLayout()
        self.contentView.collectionViewLayout.finalizeCollectionViewUpdates()
    }

    private func trackOpeningIfNeeded() {
        guard shouldTrackOnNextOpen && fetchingDone else { return }

        shouldTrackOnNextOpen = false
    }

    private func reloadData() {
        UIView.performWithoutAnimation {
            self.contentView.collectionView.performBatchUpdates({
                for section in [CollectionsSectionSet.images, CollectionsSectionSet.videos] {
                    if self.numberOfElements(for: section) != 0 {
                        self.contentView.collectionView.reloadSections(IndexSet(integer: (CollectionsSectionSet.visible.firstIndex(of: section))!))
                    }
                }
            }) { _ in
                self.contentView.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.lastLayoutSize != self.view.bounds.size {
            self.lastLayoutSize = self.view.bounds.size
            
            DispatchQueue.main.async {
                self.flushLayout()
                self.reloadData()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        trackOpeningIfNeeded()

        //UIApplication.shared.wr_updateStatusBarForCurrentControllerAnimated(true)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let _ = self.view.window else {
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.flushLayout()
        }) { _ in
            self.reloadData()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    fileprivate func updateNoElementsState() {
        self.contentView.noItemsInLibrary = self.fetchingDone && self.inOverviewMode && self.totalNumberOfElements() == 0
    }
    
    private func setupNavigationItem() {
        
        // The label must be inset from the top due to navigation bar title alignment
        let titleViewWrapper = UIView()
        let titleView = ConversationTitleView(conversation: self.collection.conversation, interactive: false)
        titleViewWrapper.addSubview(titleView)
        
        constrain(titleView, titleViewWrapper) { titleView, titleViewWrapper in
            titleView.top == titleViewWrapper.top + 4
            titleView.left == titleViewWrapper.left
            titleView.right == titleViewWrapper.right
            titleView.bottom == titleViewWrapper.bottom
        }
        
        titleViewWrapper.setNeedsLayout()
        titleViewWrapper.layoutIfNeeded()
        
        let size = titleViewWrapper.systemLayoutSizeFitting(CGSize(width: 320, height: 44))
        titleViewWrapper.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        self.navigationItem.titleView = titleViewWrapper
        
        let button = CollectionsView.closeButton()
        button.addTarget(self, action: #selector(CollectionsViewController.closeButtonPressed(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        if !self.inOverviewMode && self.navigationController?.viewControllers.count > 1 {
            let backButton = CollectionsView.backButton()
            backButton.addTarget(self, action: #selector(CollectionsViewController.backButtonPressed(_:)), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }

    @objc func closeButtonPressed(_ button: UIButton) {
        self.onDismiss?(self)
    }
    
    @objc func backButtonPressed(_ button: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

extension CollectionsViewController: AssetCollectionDelegate {
    func assetCollectionDidFetch(collection: ZMCollection, messages: [CategoryMatch : [ZMConversationMessage]], hasMore: Bool) {
        
        for messageCategory in messages {
            let conversationMessages = messageCategory.value
            
            if messageCategory.key.including.contains(.image) {
                self.imageMessages.append(contentsOf: conversationMessages)
            }
            
            if messageCategory.key.including.contains(.file) {
                self.fileAndAudioMessages.append(contentsOf: conversationMessages)
            }
            
            if messageCategory.key.including.contains(.linkPreview) {
                self.linkMessages.append(contentsOf: conversationMessages)
            }
            
            if messageCategory.key.including.contains(.video) {
                self.videoMessages.append(contentsOf: conversationMessages)
            }
        }
        
        if self.isViewLoaded {
            self.updateNoElementsState()
            self.contentView.collectionView.reloadData()
        }
    }
    
    func assetCollectionDidFinishFetching(collection: ZMCollection, result: AssetFetchResult) {
        self.fetchingDone = true
    }
}

extension CollectionsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    fileprivate func elements(for section: CollectionsSectionSet) -> [ZMConversationMessage] {
        switch(section) {
        case CollectionsSectionSet.images:
            return self.imageMessages
        case CollectionsSectionSet.filesAndAudio:
            return self.fileAndAudioMessages
        case CollectionsSectionSet.videos:
            return self.videoMessages
        case CollectionsSectionSet.links:
            return self.linkMessages
        default: fatal("Unknown section")
        }
    }
    
    fileprivate func numberOfElements(for section: CollectionsSectionSet) -> Int {
        switch(section) {
        case CollectionsSectionSet.images:
            let max = self.inOverviewMode ? self.maxOverviewElementsInGrid(in: section) : Int.max
            return min(self.imageMessages.count, max)
        
        case CollectionsSectionSet.filesAndAudio:
            let max = self.inOverviewMode ? self.maxOverviewElementsInTable : Int.max
            return min(self.fileAndAudioMessages.count, max)
            
        case CollectionsSectionSet.videos:
            let max = self.inOverviewMode ? self.maxOverviewElementsInGrid(in: section) : Int.max
            return min(self.videoMessages.count, max)
            
        case CollectionsSectionSet.links:
            let max = self.inOverviewMode ? self.maxOverviewElementsInTable : Int.max
            return min(self.linkMessages.count, max)
            
        case CollectionsSectionSet.loading:
            return 1
            
        default: fatal("Unknown section")
        }
    }
    
    fileprivate func totalNumberOfElements() -> Int {
        // Empty collection contains one element (loading cell)
        return CollectionsSectionSet.visible.map { self.numberOfElements(for: $0) }.reduce(0, +) - 1
    }
    
    fileprivate func moreElementsToSee(in section: CollectionsSectionSet) -> Bool {
        return self.elements(for: section).count > self.numberOfElements(for: section)
    }
    
    fileprivate func message(for indexPath: IndexPath) -> ZMConversationMessage {
        guard let section = CollectionsSectionSet(index: UInt(indexPath.section)) else {
            fatal("Unknown section")
        }
        
        return self.elements(for: section)[indexPath.row]
    }
    
    fileprivate func gridElementSize(in section: CollectionsSectionSet) -> CGSize {
        let sectionHorizontalInset = self.horizontalInset(in: section)

        let size = (self.contentView.collectionView.bounds.size.width - sectionHorizontalInset) / CGFloat(self.elementsPerLine(in: section))
        
        return CGSize(width: size - 1, height: size - 1)
    }
    
    fileprivate func elementsPerLine(in section: CollectionsSectionSet) -> Int {
        var count: Int = 1
        let sectionHorizontalInset = self.horizontalInset(in: section)
        
        repeat {
            count += 1
        } while ((self.contentView.collectionView.bounds.size.width - sectionHorizontalInset) / CGFloat(count) > CollectionImageCell.maxCellSize)
        
        return count
    }
    
    fileprivate func maxOverviewElementsInGrid(in section: CollectionsSectionSet) -> Int {
        return self.elementsPerLine(in: section) * 2 // 2 lines of elements
    }
    
    fileprivate var maxOverviewElementsInTable: Int {
        return 3
    }
    
    fileprivate func sizeForCell(at indexPath: IndexPath) -> (CGFloat?, CGFloat?) {
        guard let section = CollectionsSectionSet(index: UInt(indexPath.section)) else {
            fatal("Unknown section")
        }
        
        let gridElementSize = self.gridElementSize(in: section)
        
        var desiredWidth: CGFloat?
        var desiredHeight: CGFloat?
        
        switch(section) {
        case CollectionsSectionSet.images, CollectionsSectionSet.videos:
            desiredWidth = gridElementSize.width
            desiredHeight = gridElementSize.height
            
        case CollectionsSectionSet.filesAndAudio:
            desiredWidth = self.contentView.collectionView.bounds.size.width - self.horizontalInset(in: section)
            if !CollectionsView.useAutolayout {
                desiredHeight = 96
            }
        
        case CollectionsSectionSet.links:
            desiredWidth = self.contentView.collectionView.bounds.size.width - self.horizontalInset(in: section)
            if !CollectionsView.useAutolayout {
                desiredHeight = 98
            }
            
        case CollectionsSectionSet.loading:
            desiredWidth = self.contentView.collectionView.bounds.size.width - self.horizontalInset(in: section)
            if !CollectionsView.useAutolayout {
                desiredHeight = self.fetchingDone ? 24 : 88
            }
            
        default: fatal("Unknown section")
        }

        return (desiredWidth, desiredHeight)
    }
    
    fileprivate func horizontalInset(in section: CollectionsSectionSet) -> CGFloat {
        let insets = self.sectionInsets(in: section)
        return insets.left + insets.right
    }
    
    fileprivate func sectionInsets(in section: CollectionsSectionSet) -> UIEdgeInsets {
        if section == CollectionsSectionSet.loading {
            return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return self.elements(for: section).count > 0 ? UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 16) : .zero
    }

    // MARK: - Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return CollectionsSectionSet.visible.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = CollectionsSectionSet(index: UInt(section)) else {
            fatal("Unknown section")
        }
        
        return self.numberOfElements(for: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let (width, height) = self.sizeForCell(at: indexPath)
        return CGSize(width: width ?? 0, height: height ?? 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = CollectionsSectionSet(index: UInt(indexPath.section)) else {
            fatal("Unknown section")
        }
        
        let resultCell: CollectionCell
        
        switch(section) {
        case CollectionsSectionSet.images:
            resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionImageCell.reuseIdentifier, for: indexPath) as! CollectionImageCell
            
        case CollectionsSectionSet.filesAndAudio:
            if self.message(for: indexPath).fileMessageData?.isAudio == true {
                resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionAudioCell.reuseIdentifier, for: indexPath) as! CollectionAudioCell
            }
            else {
                resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionFileCell.reuseIdentifier, for: indexPath) as! CollectionFileCell
            }
            
        case CollectionsSectionSet.videos:
            resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionVideoCell.reuseIdentifier, for: indexPath) as! CollectionVideoCell
    
        case CollectionsSectionSet.links:
            resultCell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionLinkCell.reuseIdentifier, for: indexPath) as! CollectionLinkCell
            
        case CollectionsSectionSet.loading:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionLoadingCell.reuseIdentifier, for: indexPath) as! CollectionLoadingCell
            cell.collapsed = self.fetchingDone
            cell.containerWidth = collectionView.bounds.size.width - self.horizontalInset(in: section)
            return cell
        
        default: fatal("Unknown section")
        }
        
        let message = self.message(for: indexPath)
        resultCell.message = message
        resultCell.delegate = self
        resultCell.messageChangeDelegate = self
        
        if CollectionsView.useAutolayout {
            let (width, height) = self.sizeForCell(at: indexPath)
            
            resultCell.desiredWidth = width
            resultCell.desiredHeight = height
        }
        
        return resultCell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let section = CollectionsSectionSet(index: UInt(indexPath.section)) else {
            fatal("Unknown section")
        }
        
        switch (kind) {
        case UICollectionView.elementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as! CollectionHeaderView
            header.section = section
            header.totalItemsCount = UInt(self.moreElementsToSee(in: section) ? self.elements(for: section).count : 0)
            header.selectionAction = { [weak self] section in
                guard let `self` = self else {
                    return
                }
                let collectionController = CollectionsViewController(collection: self.collection, sections: section, messages: self.elements(for: section), fetchingDone: self.fetchingDone)
                collectionController.onDismiss = self.onDismiss
                collectionController.delegate = self.delegate
                self.navigationController?.pushViewController(collectionController, animated: true)
            }
            let size = self.collectionView(collectionView, layout: self.contentView.collectionView.collectionViewLayout, referenceSizeForHeaderInSection: indexPath.section)
            header.desiredWidth = size.width
            header.desiredHeight = size.height
            return header
        default:
            fatal("No supplementary view for \(kind)")
        }
    }

    // MARK: - Layout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let section = CollectionsSectionSet(index: UInt(section)) else {
            fatal("Unknown section")
        }

        if section == CollectionsSectionSet.loading {
            return .zero
        }
        return self.elements(for: section).count > 0 ? CGSize(width: collectionView.bounds.size.width, height: 48) : .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = CollectionsSectionSet(index: UInt(section)) else {
            fatal("Unknown section")
        }
        return self.sectionInsets(in: section)
    }

    // MARK: - Delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = CollectionsSectionSet(index: UInt(indexPath.section)) else {
            fatal("Unknown section for indexPath = \(indexPath)")
        }
        
        if section == .loading {
            return
        }
        
        let message = self.message(for: indexPath)

        perform(.present, for: message, source: nil)
    }
    
}

extension CollectionsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let section = CollectionsSectionSet(index: UInt(indexPath.section)) else {
                fatal("Unknown section")
            }
        
            guard section != .loading else {
                continue
            }
        }
    }
}

// MARK: - Message Change

extension CollectionsViewController: CollectionCellMessageChangeDelegate {
    func messageDidChange(_ cell: CollectionCell, changeInfo: MessageChangeInfo) {

        // Open the file when it is downloaded
        guard let message = self.selectedMessage,
              changeInfo.message == message,
              let fileMessageData = message.fileMessageData,
              fileMessageData.downloadState == .downloaded,
              self.messagePresenter.waitingForFileDownload,
              message.isFile || message.isVideo || message.isAudio else {
            return
        }
        
        self.messagePresenter.openFileMessage(message, targetView: cell)
    }
}

// MARK: - Gestures

extension CollectionsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.interactivePopGestureRecognizer == gestureRecognizer {
            return self.navigationController?.viewControllers.count > 1
        }
        else {
            return true
        }
    }
}

// MARK: - Actions
extension CollectionsViewController: MessageActionResponder {
    func perform(action: MessageAction, for message: ZMConversationMessage!, view: UIView) {
        perform(action, for: message, source: view as? CollectionCell)
    }
}

extension CollectionsViewController: CollectionCellDelegate {

    func collectionCell(_ cell: CollectionCell, performAction action: MessageAction) {
        guard let message = cell.message else {
            fatal("Cell does not have a message: \(cell)")
        }

        self.perform(action, for: message, source: cell)
    }

    func perform(_ action: MessageAction, for message: ZMConversationMessage, source: CollectionCell?) {
        switch action {
        case .copy:
            if let cell = source {
                cell.copyDisplayedContent(in: .general)
            } else {
                message.copy(in: .general)
            }

        case .delete:
            deletionDialogPresenter?.presentDeletionAlertController(forMessage: message, source: source) { [weak self] deleted in
                guard deleted else { return }
                _ = self?.navigationController?.popViewController(animated: true)
                self?.refetchCollection()
            }

        case .present:
            self.selectedMessage = message
            
            if message.isImage {
                let imagesController = ConversationImagesViewController(collection: self.collection, initialMessage: message)
                
                let backButton = CollectionsView.backButton()
                backButton.addTarget(self, action: #selector(CollectionsViewController.backButtonPressed(_:)), for: .touchUpInside)
                
                let closeButton = CollectionsView.closeButton()
                closeButton.addTarget(self, action: #selector(CollectionsViewController.closeButtonPressed(_:)), for: .touchUpInside)
                
                imagesController.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
                imagesController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
                imagesController.swipeToDismiss = false
                imagesController.messageActionDelegate = self
                navigationController?.pushViewController(imagesController, animated: true)
            } else {
                self.messagePresenter.open(message, targetView: view, actionResponder: self)
            }

        case .save:
            if message.isImage {
                guard let imageMessageData = message.imageMessageData, let imageData = imageMessageData.imageData else { return }

                let saveableImage = SavableImage(data: imageData, isGIF: imageMessageData.isAnimatedGIF)
                saveableImage.saveToLibrary()

            } else {
                guard let saveController = UIActivityViewController(message: message, from: view) else { return }
                present(saveController, animated: true, completion: nil)
            }

        case .download:
            ZMUserSession.shared()?.enqueueChanges {
                message.fileMessageData?.requestFileDownload()
            }

        case .cancel:
            ZMUserSession.shared()?.enqueueChanges {
                message.fileMessageData?.cancelTransfer()
            }

        case .like:
            ZMUserSession.shared()?.enqueueChanges {
                Message.setLikedMessage(message, liked: !message.liked)
            }

//        case .openDetails:
//            let detailsViewController = MessageDetailsViewController(message: message)
//            present(detailsViewController, animated: true)

        default:
            self.delegate?.collectionsViewController(self, performAction: action, onMessage: message)
        }
    }

}
