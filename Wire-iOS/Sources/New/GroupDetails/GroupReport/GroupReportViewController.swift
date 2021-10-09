

import UIKit

class GroupReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let cid: String
    
    private let dataSource = ["conversation.group.report.reason.pornography".localized,
                              "conversation.group.report.reason.illegalCrimes".localized,
                              "conversation.group.report.reason.gambling".localized,
                              "conversation.group.report.reason.politicalRumors".localized,
                              "conversation.group.report.reason.terror".localized,
                              "conversation.group.report.reason.other".localized]
    private let tableView = UITableView()
    
    init(cid: String) {
        self.cid = cid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "conversation.group.report.title".localized
        setupViews()
    }
    
    func setupViews() {
        let headerV = UIView()
        headerV.backgroundColor = .dynamic(scheme: .cellSelectedBackground)
        headerV.frame = CGRect.init(x: 0, y: 0, width: CGFloat.screenWidth-15, height: 42)
        
        let titleLabel = UILabel()
        titleLabel.text = "conversation.group.report.chooseReason".localized
        titleLabel.textColor = .dynamic(scheme: .note)
        titleLabel.font = UIFont(11, .medium)
        titleLabel.frame = CGRect(x: 15, y: 0, width: CGFloat.screenWidth-15, height: 42)
        headerV.addSubview(titleLabel)
        
        tableView.backgroundColor = .dynamic(scheme: .background)
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerV
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 54
        tableView.estimatedSectionHeaderHeight = 0.0
        tableView.estimatedSectionFooterHeight = 0.0
        view.addSubview(tableView)
//        tableView.autoPinEdgesToSuperviewEdges()
        tableView.secret.pin()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GroupReportTypeCell.self, forCellReuseIdentifier: "GroupReportTypeCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupReportTypeCell", for: indexPath) as! GroupReportTypeCell
        
        cell.titleText = self.dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let typ: Int = (indexPath.row == dataSource.count - 1) ? 99 : indexPath.row + 1
        let reportVC = ReportInfoViewController(type: .report(typ: typ), cid: cid)
        navigationController?.pushViewController(reportVC, animated: true)
    }
}

class GroupReportTypeCell: SettingsGroupCell {
    
    override func setup() {
        super.setup()
        self.topSeparatorLine.isHidden = true
        self.lastSeparatorLine.isHidden = true
    }
    
}
