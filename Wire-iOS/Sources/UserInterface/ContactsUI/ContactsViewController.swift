
import Foundation
import UIKit

final class ContactsViewController: UIViewController {

    let dataSource = ContactsDataSource()

    let bottomContainerView = UIView()
    let bottomContainerSeparatorView = UIView()
    let noContactsLabel = UILabel()
    let searchHeaderViewController = SearchHeaderViewController(userSelection: .init())
    let separatorView = UIView()
    let tableView = UITableView()
    let inviteOthersButton = Button(style: .empty, variant: ColorScheme.default.variant)
    let emptyResultsLabel = UILabel()

    var bottomEdgeConstraint: NSLayoutConstraint?
    var bottomContainerBottomConstraint: NSLayoutConstraint?

    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Life Cycle

    init() {
        super.init(nibName: nil, bundle: nil)

        dataSource.delegate = self
        tableView.dataSource = dataSource
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLayout()
        setupStyle()
        observeKeyboardFrame()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showKeyboardIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _ = searchHeaderViewController.tokenField.resignFirstResponder()
    }

    // MARK: - Setup

    private func setupViews() {
        setupSearchHeader()
        view.addSubview(separatorView)
        setupTableView()
        setupEmptyResultsLabel()
        setupNoContactsLabel()
        setupBottomContainer()
    }

    private func setupSearchHeader() {
        searchHeaderViewController.delegate = self
        searchHeaderViewController.allowsMultipleSelection = false
        searchHeaderViewController.view.backgroundColor = UIColor.from(scheme: .searchBarBackground, variant: .dark)
        addToSelf(searchHeaderViewController)
    }

    private func setupTableView() {
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.rowHeight = 52
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionIndexMinimumDisplayRowCount = Int(ContactsDataSource.MinimumNumberOfContactsToDisplaySections)
        ContactsCell.register(in: tableView)
        tableView.registerHeaderFooterView(ContactsSectionHeaderView.self)

        let bottomContainerHeight: CGFloat = 56.0 + UIScreen.safeArea.bottom
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomContainerHeight, right: 0)
        view.addSubview(tableView)
    }

    private func setupEmptyResultsLabel() {
        emptyResultsLabel.text = "peoplepicker.no_matching_results_after_address_book_upload_title".localized
        emptyResultsLabel.textAlignment = .center
        emptyResultsLabel.textColor = .from(scheme: .textForeground, variant: .dark)
        view.addSubview(emptyResultsLabel)
    }

    private func setupNoContactsLabel() {
        noContactsLabel.text = "peoplepicker.no_contacts_title".localized
        view.addSubview(noContactsLabel)
    }

    private func setupBottomContainer() {
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(bottomContainerSeparatorView)

        inviteOthersButton.addTarget(self, action: #selector(sendIndirectInvite), for: .touchUpInside)
        inviteOthersButton.setTitle("contacts_ui.invite_others".localized, for: .normal)
        bottomContainerView.addSubview(inviteOthersButton)
    }

    private func setupStyle() {
        title = "contacts_ui.title".localized.uppercased()
        view.backgroundColor = .dynamic(scheme: .background)

        noContactsLabel.font = .normalLightFont
        noContactsLabel.textColor = UIColor.from(scheme: .textForeground, variant: .dark)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.sectionIndexBackgroundColor = .clear
        tableView.sectionIndexColor = .accent()

        bottomContainerSeparatorView.backgroundColor = .dynamic(scheme: .separator)
        bottomContainerView.backgroundColor = UIColor.from(scheme: .searchBarBackground, variant: .dark)
    }

    // MARK: - Methods

    private func showKeyboardIfNeeded() {
        if tableView.numberOfTotalRows > StartUIViewController.InitiallyShowsKeyboardConversationThreshold {
            _ = searchHeaderViewController.tokenField.becomeFirstResponder()
        }
    }

    func updateEmptyResults(hasResults: Bool) {
        let searchQueryExist = !dataSource.searchQuery.isEmpty
        noContactsLabel.isHidden = hasResults || searchQueryExist
        setEmptyResultsHidden(hasResults)
    }

    private func setEmptyResultsHidden(_ hidden: Bool) {
        let completion: (Bool) -> Void = { finished in
            self.emptyResultsLabel.isHidden = hidden
            self.tableView.isHidden = !hidden
        }

        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: { self.emptyResultsLabel.alpha = hidden ? 0 : 1 },
                       completion: completion)
    }

    // MARK: - Keyboard Observation

    private func observeKeyboardFrame() {
        // Subscribing to the notification may cause "zero frame" animations to occur before the initial layout
        // of the view. We can avoid this by laying out the view first.
        view.layoutIfNeeded()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    @objc
    func keyboardFrameWillChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let beginFrame = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }

        let willAppear = (beginFrame.minY - endFrame.minY) > 0
        let padding: CGFloat = 12

        UIView.animate(withKeyboardNotification: notification, in: view, animations: { [weak self] keyboardFrame in
            guard let weakSelf = self else { return }
            weakSelf.bottomContainerBottomConstraint?.constant = -(willAppear ? keyboardFrame.height : 0)
            weakSelf.bottomEdgeConstraint?.constant = -padding - (willAppear ? 0 : UIScreen.safeArea.bottom)
            weakSelf.view.layoutIfNeeded()
        })
    }

}
