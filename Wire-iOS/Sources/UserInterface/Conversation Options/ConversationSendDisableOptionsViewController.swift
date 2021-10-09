
import UIKit

fileprivate enum SendDisableItem {
    case supportedValue(MessageDestructionSendDisableValue)
    case unsupportedValue(MessageDestructionSendDisableValue)
    case customValue

}

extension ZMConversation {
    fileprivate var disableItems: [SendDisableItem] {
        let newItems = MessageDestructionSendDisableValue.all.map(SendDisableItem.supportedValue)
//        if DeveloperMenuState.developerMenuEnabled() {
//            newItems.append(.customValue)
//        }
        return newItems
    }
}

extension MessageDestructionSendDisableValue {

    var localizedText: String? {
        guard .none != self else { return "input.ephemeral.timeout.none".localized }
        if case .forever = self {
            return "conversation.setting.disableSendMsg.duration.forever".localized
        }
        return longStyleFormatter.string(from: TimeInterval(rawValue))
    }
    
    private var longStyleFormatter: DateComponentsFormatter {
        var cal = Calendar.current
        cal.locale = Language.locale
        let formatter = DateComponentsFormatter()
        formatter.calendar = cal
        formatter.includesApproximationPhrase = false
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .weekOfMonth, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
    }
}

class ConversationSendDisableOptionsViewController: UIViewController {
    
    fileprivate let conversation: ZMConversation
    fileprivate var items: [SendDisableItem] = []
    fileprivate let userSession: ZMUserSession
    fileprivate let user: ZMUser
    fileprivate var observerToken: Any! = nil
    
    public weak var dismisser: ViewControllerDismisser?
    
    private var selectIndex: IndexPath = IndexPath.init(row: 0, section: 0)
    
    private let collectionViewLayout = UICollectionViewFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    }()
    
    // MARK: - Initialization
    
    public init(conversation: ZMConversation, userSession: ZMUserSession, user: ZMUser) {
        self.conversation = conversation
        self.userSession = userSession
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.updateItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "conversation.setting.disableSendMsg".localized.uppercased()
        
        configureSubviews()
        configureConstraints()
    }
    
    private func configureSubviews() {
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .dynamic(scheme: .background)
        collectionView.alwaysBounceVertical = true
        
        collectionViewLayout.minimumLineSpacing = 0
        
        LeftCheckmarkCell.register(in: collectionView)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
    }
    
    private func configureConstraints() {
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.fitInSuperview()
    }
    
}

// MARK: - Table View

extension ConversationSendDisableOptionsViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        let cell = collectionView.dequeueReusableCell(ofType: LeftCheckmarkCell.self, for: indexPath)
        
        func configure(_ cell: LeftCheckmarkCell, for value: MessageDestructionSendDisableValue, disabled: Bool) {
            cell.title = value.localizedText
            cell.disabled = disabled
            cell.showCheckmark = indexPath == selectIndex
        }
        
        switch item {
        case .supportedValue(let value):
            configure(cell, for: value, disabled: false)
        case .unsupportedValue(let value):
            configure(cell, for: value, disabled: true)
        case .customValue:
            cell.title = "Custom"
            cell.showCheckmark = false
        }
        
        cell.showSeparator = indexPath.row < (items.count - 1)
        
        return cell
    }
    
    private func updateItems() {
        self.items = conversation.disableItems
        self.caculateBlockTime()
    }
    
    private func caculateBlockTime() {
        let userID = self.user.remoteIdentifier.transportString()
        guard
            let context = self.conversation.managedObjectContext,
            let conversationID = self.conversation.remoteIdentifier?.transportString(),
            let blockTime = UserDisableSendMsgStatus.getBlockTime(managedObjectContext: context, user: userID, conversation: conversationID),
            blockTime != 0
            else { return }
        
        if blockTime == -1 {
            self.selectIndex = IndexPath(row: self.items.count - 1, section: 0)
            return
        }
        let duration = blockTime.int64Value - Int64(Date().timeIntervalSince1970)
        if let index = MessageDestructionSendDisableValue.all.firstIndex(where: { Int64($0.rawValue) > duration }),
            index > 0 {
            self.selectIndex = IndexPath(row: index, section: 0)
        }
    }
    
    private func updateDisable(_ timeout: MessageDestructionSendDisableValue) {
        
        guard let context = self.conversation.managedObjectContext?.zm_sync else { return }
        guard let convid = self.conversation.remoteIdentifier?.transportString() else { return }
        let uid = self.user.remoteIdentifier.transportString()
        guard let managedObjectContext = self.conversation.managedObjectContext else { return }
        let oldBlockTime = UserDisableSendMsgStatus.getBlockTime(managedObjectContext: managedObjectContext, user: uid, conversation: convid)
        var blockTime: Int64 = 0
        if timeout.rawValue == 0 || timeout.rawValue == -1 {
            blockTime = Int64(timeout.rawValue)
        } else {
            blockTime = Int64(NSDate().timeIntervalSince1970 + timeout.rawValue)
        }
        if oldBlockTime?.int64Value == 0 &&  blockTime == 0{
            self.navigationController?.popViewController(animated: true)
            return
        }
        context.perform {
            UserDisableSendMsgStatus.update(managedObjectContext: context, block_time: NSNumber(value: blockTime), block_duration: NSNumber(value: timeout.rawValue), user: uid, conversation: convid,fromPushChannel: false)
            context.saveOrRollback()
        }
        self.collectionView.reloadData()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func handle(error: Error) {
        let controller = UIAlertController.checkYourConnection()
        present(controller, animated: true)
    }
    
    private func requestCustomValue() {
        UIAlertController.requestCustomTimeInterval(over: self) { [weak self] result in
            
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success(let value):
                self.updateDisable(MessageDestructionSendDisableValue(rawValue: value))
            default:
                break
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let selectedItem = items[indexPath.row]
        selectIndex = indexPath
        switch selectedItem {
        case .supportedValue(let value):
            updateDisable(value)
        case .customValue:
            requestCustomValue()
        default:
            break
        }
        
    }
    
    // MARK: Layout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 32)
    }
    
}

private class LeftCheckmarkCell: RightIconDetailsCell {
    
    var showCheckmark: Bool = false {
        didSet {
            updateCheckmark()
        }
    }
    
    override var disabled: Bool {
        didSet {
            updateCheckmark()
        }
    }
    
    override func setUp() {
        super.setUp()
        icon = StyleKitIcon.checkmark.makeImage(size: .tiny, color: .clear)
        status = nil
    }
    
    private func updateCheckmark() {
        guard showCheckmark else {
            accessory = nil
            return
        }
        icon = StyleKitIcon.checkmark.makeImage(size: .tiny, color: .dynamic(scheme: .brand))
    }
}
