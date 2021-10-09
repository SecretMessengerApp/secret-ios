
import UIKit
import MessageUI
import WireSystem

typealias TechnicalReport = [String: String]

final class SettingsTechnicalReportViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    static private let technicalReportTitle = "TechnicalReportTitleKey"
    static private let technicalReportData = "TechnicalReportDataKey"
    
    private let includedVoiceLogCell: UITableViewCell
    private let sendReportCell: UITableViewCell
    
    init() {
        sendReportCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        sendReportCell.backgroundColor = UIColor.clear
        sendReportCell.textLabel?.text = "self.settings.technical_report.send_report".localized
        sendReportCell.textLabel?.textColor = UIColor.accent()
        sendReportCell.backgroundColor = UIColor.clear
        sendReportCell.backgroundView = UIView()
        sendReportCell.selectedBackgroundView = UIView()
        
        includedVoiceLogCell = UITableViewCell(style: .default, reuseIdentifier: nil)
        includedVoiceLogCell.accessoryType = .checkmark
        includedVoiceLogCell.textLabel?.text = "self.settings.technical_report.include_log".localized
        includedVoiceLogCell.textLabel?.textColor = UIColor.dynamic(scheme: .title)
        includedVoiceLogCell.backgroundColor = UIColor.clear
        includedVoiceLogCell.backgroundView = UIView()
        includedVoiceLogCell.selectedBackgroundView = UIView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("self.settings.technical_report_section.title", comment: "").localizedUppercase
        tableView.backgroundColor = UIColor.clear
        tableView.isScrollEnabled = false
        tableView.separatorColor = UIColor(white: 1, alpha: 0.1)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateStatusBar()
    }
    
    func sendReport(sourceView: UIView? = nil) {
        let mailRecipient = "ios@isecret.im"

        guard MFMailComposeViewController.canSendMail() else {
            DebugAlert.displayFallbackActivityController(logPaths: ZMSLog.pathsForExistingLogs, email: mailRecipient, from: self, sourceView: sourceView)
            return
        }

        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients([mailRecipient])
        mailComposeViewController.setSubject(NSLocalizedString("self.settings.technical_report.mail.subject", comment: ""))
        
        if includedVoiceLogCell.accessoryType == .checkmark {
            if let currentLog = ZMSLog.currentLog, let currentPath = ZMSLog.currentLogPath {
                mailComposeViewController.addAttachmentData(currentLog, mimeType: "text/plain", fileName: currentPath.lastPathComponent)
            }
            if let previousLog = ZMSLog.previousLog, let previousPath = ZMSLog.previousLogPath {
                mailComposeViewController.addAttachmentData(previousLog, mimeType: "text/plain", fileName: previousPath.lastPathComponent)
            }
            if let currentExLog = ExLog.currentLog, let path = ExLog.currentLogPath {
                mailComposeViewController.addAttachmentData(currentExLog, mimeType: "text/plain", fileName: path.lastPathComponent)
            }
        }

        mailComposeViewController.setMessageBody("Debug report", isHTML: false)

        self.present(mailComposeViewController, animated: true, completion: nil)
    }
    
    // MARK TableView Delegates

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return indexPath.row == 0 ? includedVoiceLogCell : sendReportCell
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "self.settings.technical_report.privacy_warning".localized
        label.textColor = UIColor.from(scheme: .textDimmed)
        label.backgroundColor = .clear
        label.font = FontSpec(.small, .light).font!
        
        let container = UIView()
        container.addSubview(label)
        container.layoutMargins = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
        container.backgroundColor = .clear

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.topAnchor.constraint(equalTo: container.layoutMarginsGuide.topAnchor),
                                     label.bottomAnchor.constraint(equalTo: container.layoutMarginsGuide.bottomAnchor),
                                     label.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
                                     label.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor)])
        return container
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            includedVoiceLogCell.accessoryType = includedVoiceLogCell.accessoryType == .none ? .checkmark : .none
        } else {
            let cell = tableView.cellForRow(at: indexPath)
            sendReport(sourceView: cell)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Mail Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    
}
