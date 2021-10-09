

import UIKit

class ConversationListPopoverBackgroundView: UIPopoverBackgroundView {
    
    override class func arrowBase() -> CGFloat { return 12.0 }
    override class func arrowHeight() -> CGFloat { return 8.0 }
    override class func contentViewInsets() -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 0, right: -9)
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get { return self.arrDir }
        set { self.arrDir = newValue }
    }
    
    override var arrowOffset: CGFloat {
        get { return self.arrOff }
        set { self.arrOff = newValue }
    }
    
    override class var wantsDefaultContentAppearance: Bool {
        return true
    }
    
    private var arrOff: CGFloat
    private var arrDir: UIPopoverArrowDirection
    private let arrow = UIImageView(image: UIImage(named: "popover_triangle"))
    
    override init(frame:CGRect) {
        self.arrDir = .up
        self.arrOff = 0
        super.init(frame:frame)
        addSubview(arrow)
        layer.shadowColor = UIColor.clear.cgColor
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var arrowFrame = arrow.frame
        arrowFrame.origin.x = frame.width - 10
        arrow.frame = arrowFrame
    }
}


class ConversationListPopoverController: UITableViewController {
    
    var didSelectCell: ((CellType) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attr = [NSAttributedString.Key.font: UIFont(16, .medium)]
        var maxW = dataSource.map { $0.localized.size(withAttributes: attr).width }.max() ?? 120
        maxW = max(maxW + 65, 120)
        preferredContentSize = CGSize(width: maxW, height: 50 * CGFloat(dataSource.count))
        tableView.isScrollEnabled = false
        tableView.rowHeight = 50
        tableView.tableFooterView = UIView()
        tableView.registerCell(UITableViewCell.self)
        tableView.separatorStyle = .none
    }
    
    enum CellType: Int {
        case group = 0, add, scan
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.superview?.layer.cornerRadius = 2
    }
    
    private let dataSource = ["conversation_list.popover.group_chat",
                              "conversation_list.popover.add_friend",
                              "conversation_list.popover.scan"]
    private let imgs = ["convseration_list_popover_group",
                        "convseration_list_popover_add",
                        "convseration_list_popover_scan"]
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(UITableViewCell.self)
        cell.backgroundColor = .dynamic(scheme: .popoverBackground)
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .dynamic(scheme: .popoverBackground)
        cell.textLabel?.text = dataSource[indexPath.row].localized
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(15, .medium)
        cell.imageView?.image = UIImage(named: imgs[indexPath.row])
        let line = UIView()
        let isLast = indexPath.row == (dataSource.count - 1)
        line.backgroundColor = isLast ? .clear : UIColor(hex: "#4B4B4B")
        cell.contentView.addSubview(line)
        
        line.translatesAutoresizingMaskIntoConstraints = false
        line.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        line.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
        line.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 47).isActive = true
        line.heightAnchor.constraint(equalToConstant: .hairline).isActive = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = CellType(rawValue: indexPath.row)!
        didSelectCell?(type)
        dismiss(animated: false, completion: nil)
    }
}
