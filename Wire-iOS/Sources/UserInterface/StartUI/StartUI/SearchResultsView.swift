
import Foundation

final class SearchResultsView : UIView {
    
    let accessoryViewMargin : CGFloat = 16.0
    let emptyResultContainer = UIView()

    @objc
    let collectionView : UICollectionView
    let collectionViewLayout : UICollectionViewFlowLayout
    let accessoryContainer = UIView()
    var lastLayoutBounds : CGRect = CGRect.zero
    var accessoryContainerHeightConstraint: NSLayoutConstraint?
    var accessoryViewBottomOffsetConstraint : NSLayoutConstraint?
    weak var parentViewController: UIViewController?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init() {
        collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .vertical
        collectionViewLayout.minimumInteritemSpacing = 12
        collectionViewLayout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .dynamic(scheme: .barBackground)
        collectionView.allowsMultipleSelection = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        super.init(frame: CGRect.zero)

        addSubview(collectionView)
        addSubview(accessoryContainer)
        addSubview(emptyResultContainer)        
        createConstraints()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameDidChange(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyResultContainer.translatesAutoresizingMaskIntoConstraints = false
        accessoryContainer.translatesAutoresizingMaskIntoConstraints = false

        accessoryContainerHeightConstraint = accessoryContainer.heightAnchor.constraint(equalToConstant: 0)
        accessoryViewBottomOffsetConstraint = accessoryContainer.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            // collectionView
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: accessoryContainer.topAnchor),

            // emptyResultContainer
            emptyResultContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyResultContainer.topAnchor.constraint(equalTo: topAnchor),
            emptyResultContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyResultContainer.bottomAnchor.constraint(equalTo: accessoryContainer.topAnchor),

            accessoryContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            accessoryContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            accessoryContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            accessoryContainerHeightConstraint!,
            accessoryViewBottomOffsetConstraint!,
        ])
    }
    
    override func layoutSubviews() {
        if !lastLayoutBounds.equalTo(bounds) {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        
        lastLayoutBounds = bounds
        
        super.layoutSubviews()
    }

    @objc
    var accessoryView : UIView? {
        didSet {
            guard oldValue != accessoryView else { return }
            
            oldValue?.removeFromSuperview()
            
            if let accessoryView = accessoryView {
                accessoryContainer.addSubview(accessoryView)
                accessoryView.translatesAutoresizingMaskIntoConstraints = false
                accessoryContainerHeightConstraint?.isActive = false

                NSLayoutConstraint.activate([
                    accessoryView.leadingAnchor.constraint(equalTo: accessoryContainer.leadingAnchor),
                    accessoryView.topAnchor.constraint(equalTo: accessoryContainer.topAnchor),
                    accessoryView.trailingAnchor.constraint(equalTo: accessoryContainer.trailingAnchor),
                    accessoryView.bottomAnchor.constraint(equalTo: accessoryContainer.bottomAnchor)
                ])
            }
            else {
                accessoryContainerHeightConstraint?.isActive = true
            }
 
//            updateContentInset()
        }
    }

    @objc
    var emptyResultView : UIView? {
        didSet {
            guard oldValue != emptyResultView else { return }
            
            oldValue?.removeFromSuperview()
            
            if let emptyResultView = emptyResultView {
                emptyResultContainer.addSubview(emptyResultView)
                emptyResultView.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    emptyResultView.leadingAnchor.constraint(equalTo: emptyResultContainer.leadingAnchor),
                    emptyResultView.topAnchor.constraint(equalTo: emptyResultContainer.topAnchor),
                    emptyResultView.trailingAnchor.constraint(equalTo: emptyResultContainer.trailingAnchor),
                    emptyResultView.bottomAnchor.constraint(equalTo: emptyResultContainer.bottomAnchor)
                ])
            }

            emptyResultContainer.setNeedsLayout()
        }
    }
    
    @objc func keyboardFrameDidChange(notification: Notification) {
        if let parentViewController = parentViewController, parentViewController.isContainedInPopover() {
            return
        }
        
        let firstResponder = UIResponder.currentFirst
        let inputAccessoryHeight = firstResponder?.inputAccessoryView?.bounds.size.height ?? 0
        
        UIView.animate(withKeyboardNotification: notification, in: self, animations: {
            [weak self] (keyboardFrameInView)  in
            let keyboardHeight = keyboardFrameInView.size.height - inputAccessoryHeight
            self?.accessoryViewBottomOffsetConstraint?.constant = -keyboardHeight
            self?.layoutIfNeeded()
        }, completion: nil)
    }

    private func updateContentInset() {

        if let accessoryView = self.accessoryView {
            accessoryView.layoutIfNeeded()
            let bottomInset = (UIScreen.hasNotch ? accessoryViewMargin : 0) + accessoryView.frame.height - UIScreen.safeArea.bottom

            // Add padding at the bottom of the screen
            collectionView.contentInset.bottom = bottomInset
            collectionView.scrollIndicatorInsets.bottom  = bottomInset
        } else {
            collectionView.contentInset.bottom = 0
            collectionView.scrollIndicatorInsets.bottom = 0
        }

    }
    
}
