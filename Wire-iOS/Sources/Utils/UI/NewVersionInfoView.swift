//
//  NewVersionInfoView.swift
//  Wire-iOS
//


import UIKit
import Cartography

class NewVersionInfoView: UIView {

    @objc static func showIfNewVersionAvailable(
        animate: Bool = true,
        onView: UIView,
        dismissKnowMoreAction: (() -> Void)? = nil,
        dismissNoAction: (() -> Void)? = nil
        ) {
        let checker = NewVersionChecker()
        guard checker.isNewVersionAvailable else { return }
        checker.syncVersion()
        let view = NewVersionInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        onView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: onView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: onView.trailingAnchor),
            view.topAnchor.constraint(equalTo: onView.topAnchor),
            view.bottomAnchor.constraint(equalTo: onView.bottomAnchor)
        ])
        onView.bringSubviewToFront(view)
        view.dismissKnowMoreAction = dismissKnowMoreAction
        view.dismissNoAction = dismissNoAction
        if animate { view.applyAnimate(on: view.container) }
    }

    // MARK: - Init
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addViews()
        addActions()
        createConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var dismissKnowMoreAction: (() -> Void)?
    private var dismissNoAction: (() -> Void)?

    // MARK: - Private Funcs
    private func applyAnimate(on: UIView) {
        on.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.7,
                       options: .curveEaseInOut,
                       animations: {
            on.transform = .identity
        }, completion: nil)
    }
    private func addViews() {
        addSubview(container)
        [topContainer, bottomContainer].forEach(container.addSubview)
        [imgView, closeBtn].forEach(topContainer.addSubview)
        [titleLabel, tableView,
         /*knowMoreBtn,*/ cancelBtn].forEach(bottomContainer.addSubview)
    }
    private func addActions() {
        closeBtn.addTarget(self, action: #selector(closeBtnClicked), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClicked), for: .touchUpInside)
//        knowMoreBtn.addTarget(self, action: #selector(knowMoreBtnClicked), for: .touchUpInside)
    }
    @objc private func closeBtnClicked() {
        dismiss(completion: dismissNoAction)
    }
    @objc private func cancelBtnClicked() {
        dismiss(completion: dismissNoAction)
    }
//    @objc private func knowMoreBtnClicked() {
//        dismiss(completion: dismissKnowMoreAction)
//    }

    private func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
            self.removeFromSuperview()
        }) { _ in
            completion?()
        }
    }

    private func createConstraints() {
        constrain(container, self) { (container, father) in
            container.left == father.left + 35
            container.right == father.right - 35
            container.top == father.top + 95
            container.bottom == father.bottom - 95
        }

        constrain(topContainer, bottomContainer, container) { (topc, botc, c) in
            topc.left == c.left
            topc.right == c.right
            topc.top == c.top
            topc.height == 160

            botc.left == c.left
            botc.right == c.right
            botc.top == topc.bottom
            botc.bottom == c.bottom
        }

        constrain(imgView, closeBtn, topContainer) { (img, close, c) in
            img.centerX == c.centerX
            img.bottom == c.bottom

            close.right == c.right - 15
            close.top == c.top + 15
        }

        constrain(titleLabel, tableView, /*knowMoreBtn,*/ cancelBtn, bottomContainer) { (title, text, /*knowMore,*/ cancel, c) in
            title.top == c.top + 20
            title.centerX == c.centerX

            text.top == title.bottom + 20
            text.left == c.left + 40
            text.right == c.right - 40
            text.bottom >= cancel.top - 20

            cancel.left == text.left
            cancel.right == text.right
            cancel.height == 40
            cancel.bottom == c.bottom - 40

//            text.bottom == knowMore.top - 40

//            knowMore.bottom == c.bottom - 40
//            knowMore.right == c.centerX - 5
//            knowMore.width == 100
//            knowMore.height == 40

//            cancel.width == knowMore.width
//            cancel.height == knowMore.height
//            cancel.centerY == knowMore.centerY
//            cancel.left == c.centerX + 5
        }
    }

    private var container: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.dynamic(scheme: .cellBackground)
        return view
    }()
    private var topContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .brand)
        return view
    }()
    private var bottomContainer: UIView = {
        let view = UIView()
        return view
    }()
    private var imgView = UIImageView(image: UIImage(named: "version_info_img"))
    private var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "version_info_btn_close"), for: .normal)
        return btn
    }()
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(25, .medium)
//        Introduce read return receipt
        let dffd = WRTools.getBundleShortVersionString()
        label.text = "V\(WRTools.getBundleShortVersionString())\("new_version_title".localized)"
        label.textColor = UIColor.dynamic(scheme: .title)
        return label
    }()
    private var textView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont(14, .medium)
        textView.textColor = UIColor.dynamic(scheme: .title)
        textView.isEditable = false
        textView.text = "new_version_info".localized
        return textView
    }()
    
    fileprivate lazy var tableView: UITableView = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        let view = UIView()
        view.backgroundColor = .clear
        tableV.tableFooterView = view
        tableV.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableV.backgroundColor = .dynamic(scheme: .cellBackground)
        return tableV
    }()
    fileprivate var datasource: [String] = {
        var dataS = "new_version_info".localized.components(separatedBy: "\n")
        return dataS
    }()
//    private var knowMoreBtn: UIButton = {
//        let btn = UIButton()
//        btn.setTitleColor(.white, for: .normal)
//        btn.layer.cornerRadius = 20
//        btn.backgroundColor = UIColor(hex: 0x2C2C36)
//        btn.setTitle("", for: .normal)
//        return btn
//    }()
    private var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 20
        btn.backgroundColor = UIColor(hex: "#2C2C36")
        btn.setTitle("general.ok".localized, for: .normal)
        return btn
    }()
}

extension NewVersionInfoView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewVersionInfoViewCellID")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "NewVersionInfoViewCellID")
        }
        cell?.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell?.selectionStyle = .none
        cell?.backgroundColor = .dynamic(scheme: .cellBackground)
        let indexlab = UILabel()
        indexlab.text = "\(indexPath.row + 1)."
        indexlab.font = UIFont(14, .regular)
        let deslab = UILabel()
        deslab.textAlignment = NSTextAlignment.left
        let desc = self.datasource[indexPath.row]
        
        deslab.text = desc.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        deslab.font = UIFont(14, .regular)
        deslab.numberOfLines = 0
        [indexlab, deslab].forEach({cell?.contentView.addSubview($0)})
        
        constrain(indexlab, deslab, cell!.contentView) { (indexlab, deslab, contentview) in
            indexlab.left == contentview.left
            indexlab.top == contentview.top
            indexlab.height == 20
            indexlab.width == 20
            deslab.top == indexlab.top + 2
            deslab.left == indexlab.right
            deslab.bottom == contentview.bottom - 2
            deslab.right == contentview.right
        }
        return cell!
    }
}


class NewVersionChecker: NSObject {
    
    var isNewVersionAvailable: Bool = false
    
    override init() {
        super.init()
        self.isNewVersionAvailable = check()
    }
    
    func syncVersion() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(newVersion, forKey: kAppVersionKey)
        userDefaults.synchronize()
    }
    
    private func check() -> Bool {
        let old = UserDefaults.standard.string(forKey: kAppVersionKey) ?? defaultVersion
        return old.compare(newVersion, options: .numeric) == .orderedAscending
    }
    
    private var newVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? defaultVersion
    }
    
    private let defaultVersion = "0.0.0"
    
    private let kAppVersionKey = "SecretAppVersionKey"
}
