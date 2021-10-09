

import UIKit
import Cartography

class SettingsBaseTableViewController: UIViewController {

    var tableView: UITableView
    let topSeparator = OverflowSeparatorView()
    let footerSeparator = OverflowSeparatorView()
    private let footerContainer = UIView()

    public var footer: UIView? {
        didSet {
            updateFooter(footer)
        }
    }

    final fileprivate class IntrinsicSizeTableView: UITableView {
        override var contentSize: CGSize {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }

        override var intrinsicContentSize: CGSize {
            layoutIfNeeded()
            return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
        }
    }
    
    init(style: UITableView.Style) {
        tableView = IntrinsicSizeTableView(frame: .zero, style: style)
        super.init(nibName: nil, bundle: nil)
        self.edgesForExtendedLayout = UIRectEdge()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    override func viewDidLoad() {
        self.createTableView()
        self.view.addSubview(self.topSeparator)
        self.topSeparator.alpha = 1
        self.createConstraints()
        self.view.backgroundColor = .dynamic(scheme: .groupBackground)
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    private func createTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.clipsToBounds = true
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
        view.addSubview(tableView)
        view.addSubview(footerContainer)
        footerContainer.addSubview(footerSeparator)
        footerSeparator.inverse = true
        footerSeparator.alpha = 1

        if self.tableView.style == .grouped {
            if #available(iOS 11.0, *) {
                tableView.estimatedSectionFooterHeight = 0.01
                tableView.estimatedSectionHeaderHeight = 0.01
            }
        }
    }

    private func createConstraints() {
        constrain(view, tableView, topSeparator, footerContainer, footerSeparator) { view, tableView, topSeparator, footerContainer, footerSeparator in
            tableView.left == view.left
            tableView.right == view.right
            tableView.top == view.top

            topSeparator.left == tableView.left
            topSeparator.right == tableView.right
            topSeparator.top == tableView.top

            footerContainer.top == tableView.bottom
            footerContainer.left == tableView.left
            footerContainer.right == tableView.right
            footerContainer.bottom == view.bottom
            footerContainer.height == 0 ~ 750.0
            
            footerSeparator.left == footerContainer.left
            footerSeparator.right == footerContainer.right
            footerSeparator.top == footerContainer.top
        }
    }

    private func updateFooter(_ newFooter: UIView?) {
        footer?.removeFromSuperview()
        footerSeparator.isHidden = newFooter == nil
        guard let newFooter = newFooter else { return }
        footerContainer.addSubview(newFooter)
        constrain(footerContainer, newFooter) { container, footer in
            footer.edges == container.edges
        }
    }

    
}

extension SettingsBaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        self.topSeparator.scrollViewDidScroll(scrollView: scrollView)
        self.footerSeparator.scrollViewDidScroll(scrollView: scrollView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        fatalError("Subclasses need to implement this method")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Subclasses need to implement this method")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Subclasses need to implement this method")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }

}
@objc protocol ConversationSettingsTableViewControllerDelegate {
    @objc optional func onClickConversationRecordCell()
    @objc optional func onClickCreateConversationCell()
    @objc optional func onClickRemoveParticipantCell()
    @objc optional func onClickStartChatCell()
//    @objc optional func onClickPhotoCell()
//    @objc optional func onClickDestoryAfterReadCell()
}

class SettingsTableViewController: SettingsBaseTableViewController {

    var group: SettingsInternalGroupCellDescriptorType {
        didSet {
            self.title = self.group.title.localizedUppercase
            self.group.items.flatMap { return $0.cellDescriptors }.forEach {
                if let groupDescriptor = $0 as? SettingsGroupCellDescriptorType {
                    groupDescriptor.viewController = self
                }
            }
            tableView.reloadData()
        }
    }

    fileprivate var sections: [SettingsSectionDescriptorType]

    fileprivate var selfUserObserver: NSObjectProtocol!
    weak var delegate: ConversationSettingsTableViewControllerDelegate?
    
    required init(group: SettingsInternalGroupCellDescriptorType) {
        self.group = group
        self.sections = group.visibleItems
        super.init(style: group.style == .plain ? .plain : .grouped)
        self.title = group.title.localizedUppercase
        
        self.group.items.flatMap { return $0.cellDescriptors }.forEach {
            if let groupDescriptor = $0 as? SettingsGroupCellDescriptorType {
                groupDescriptor.viewController = self
            }
        }

        if let userSession = ZMUserSession.shared() {
            self.selfUserObserver = UserChangeInfo.add(observer: self, for: ZMUser.selfUser(), userSession: userSession)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        
//        self.navigationItem.rightBarButtonItem = navigationController?.closeItem()
    }

    func setupTableView() {
        let allCellTypes: [SettingsTableCell.Type] = [SettingsTableCell.self, SettingsGroupCell.self, SettingsButtonCell.self, SettingsToggleCell.self, SettingsValueCell.self, SettingsTextCell.self, SettingsStaticTextTableCell.self]

        for aClass in allCellTypes {
            tableView.register(aClass, forCellReuseIdentifier: aClass.reuseIdentifier)
        }

        if self.group.visibleItems[0].header == nil, self.tableView.style == .grouped {
            self.tableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        }
    }
    
    func refreshData() {
        sections = group.visibleItems
        tableView.reloadData()
    }

    // MARK: - UITableViewDelegate & UITableViewDelegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDescriptor = sections[section]
        return sectionDescriptor.visibleCellDescriptors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionDescriptor = sections[(indexPath as NSIndexPath).section]
        let cellDescriptor = sectionDescriptor.visibleCellDescriptors[(indexPath as NSIndexPath).row]

        if let cell = tableView.dequeueReusableCell(withIdentifier: type(of: cellDescriptor).cellType.reuseIdentifier, for: indexPath) as? SettingsTableCell {
            cell.descriptor = cellDescriptor
            cellDescriptor.featureCell(cell)
            cell.isFirst = indexPath.row == 0
            cell.isLast = indexPath.row == (self.group.visibleItems[indexPath.section].visibleCellDescriptors.count - 1)
            return cell
        }

        fatalError("Cannot dequeue cell for index path \(indexPath) and cellDescriptor \(cellDescriptor)")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sectionDescriptor = sections[(indexPath as NSIndexPath).section]
        let property = sectionDescriptor.visibleCellDescriptors[(indexPath as NSIndexPath).row]

        property.select(Optional.none)
        tableView.deselectRow(at: indexPath, animated: false)
        switch property.identifier {
        case SettingsCellDescriptorId.createConversation.rawValue?:
            self.delegate?.onClickCreateConversationCell?()
        case SettingsCellDescriptorId.conversationRecord.rawValue?:
            self.delegate?.onClickConversationRecordCell?()
        case SettingsCellDescriptorId.removePeople.rawValue?:
            self.delegate?.onClickRemoveParticipantCell?()
        case SettingsCellDescriptorId.startChat.rawValue?:
            self.delegate?.onClickStartChatCell?()
        default: break
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDescriptor = sections[section]
        return sectionDescriptor.header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionDescriptor = sections[section]
        return sectionDescriptor.footer
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor.dynamic(scheme: .subtitle)
        }
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerFooterView = view as? UITableViewHeaderFooterView {
            headerFooterView.textLabel?.textColor = UIColor.dynamic(scheme: .subtitle)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.header != nil ? 32 : 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionDescriptor = self.group.visibleItems[section]
        return sectionDescriptor.footer != nil ? UITableView.automaticDimension : CGFloat.leastNormalMagnitude
    }

}

extension SettingsTableViewController {
    
    @objc
    func applicationDidBecomeActive() {
        refreshData()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        userInterfaceStyleDidChange(previousTraitCollection) { [weak self] _ in
            self?.refreshData()
        }
    }
}

extension SettingsTableViewController: ZMUserObserver {
    
    func userDidChange(_ note: UserChangeInfo) {
        if  note.accentColorValueChanged ||
            note.imageSmallProfileDataChanged ||
            note.imageMediumDataChanged {
            refreshData()
        }
    }
}
