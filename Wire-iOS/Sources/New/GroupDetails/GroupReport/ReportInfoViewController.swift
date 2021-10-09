

import UIKit

class ReportInfoViewController: UIViewController, UITextViewDelegate {

    enum ViewType {
        case report(typ: Int)
        case unblock
        
        var title: String {
            switch self {
            case .report:
                return "conversation.group.report.describeReport".localized
            case .unblock:
                return "conversation.group.report.applyUnblocking".localized
            }
        }
        var textVPlaceholdText: String {
            switch self {
            case .report:
                return "conversation.group.report.clearlyDescribeReport".localized
            case .unblock:
                return "conversation.group.report.applyUnblockingDesc".localized
            }
        }
        var commintTitle: String {
            switch self {
            case .report:
                return "conversation.group.report.commitReport".localized
            case .unblock:
                return "newProfile.conversation.complaint.submit".localized
            }
        }
    }
    
    private let cid: String
    private let type: ViewType
    
    private let placeholdBtn = UIButton()
    private let introTextV = UITextView()
    private let wordLimitlabel = UILabel()
    
    private let uploadPlaceholdBtn = UIButton()
    private let commitBtn: Button = Button(style: .full)
    
    private var mediaButton: UIButton!
    fileprivate var photosView: SelectedPhotosView?
    private var chooseMediaItems: [WRChooseMediaItem]?
    
    init(type: ViewType, cid: String) {
        self.type = type
        self.cid = cid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = type.title
        self.setupViews()
        
        if self.navigationController?.viewControllers.count == 1 {
            self.navigationItem.rightBarButtonItem = self.navigationController?.closeItem()
        }
    }

    func setupViews() {
        self.view.backgroundColor = .dynamic(scheme: .background)
        
        introTextV.textColor = .dynamic(scheme: .title)
        introTextV.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
        introTextV.font = UIFont(16, .medium)
        introTextV.backgroundColor = .dynamic(scheme: .inputBackground)
        introTextV.layer.cornerRadius = 3
        introTextV.layer.masksToBounds = true
        self.view.addSubview(introTextV)
        introTextV.frame = CGRect.init(x: 15, y: 15, width: CGFloat.screenWidth - 30, height: 192)
        introTextV.delegate = self
        
        placeholdBtn.titleLabel?.font = UIFont(16, .medium)
        placeholdBtn.setTitleColor(.dynamic(scheme: .note), for: .normal)
        placeholdBtn.setTitle(type.textVPlaceholdText.localized, for: .normal)
        self.view.addSubview(placeholdBtn)
        placeholdBtn.contentHorizontalAlignment = .left
        placeholdBtn.frame = CGRect.init(x: introTextV.frame.minX + 8, y: introTextV.frame.minY + 5, width: introTextV.frame.width, height: 25)
        placeholdBtn.addTarget(self, action: #selector(btnPlaceholdAction), for: .touchUpInside)
        
        wordLimitlabel.text = "0/200"
        wordLimitlabel.textAlignment = .right
        wordLimitlabel.font = UIFont(13, .regular)
        wordLimitlabel.textColor = .dynamic(scheme: .note)
        self.view.addSubview(wordLimitlabel)
        wordLimitlabel.frame = CGRect.init(x: introTextV.frame.maxX - 100 - 8, y: introTextV.frame.maxY - 15 - 8, width: 100, height: 15)
        
        commitBtn.alpha = 0.6
        commitBtn.titleLabel?.font = FontSpec.init(.small, .medium, .largeTitle).font
        commitBtn.setBackgroundImageColor(.dynamic(scheme: .brand), for: .normal)
        commitBtn.setTitle(type.commintTitle.localized, for: .normal)
        commitBtn.isUserInteractionEnabled = false
        self.view.addSubview(commitBtn)
        commitBtn.addTarget(self, action: #selector(commitAction), for: .touchUpInside)
//        commitBtn.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
//        commitBtn.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
//        commitBtn.autoPinEdge(toSuperviewEdge: .bottom, withInset: 40)
//        commitBtn.autoSetDimension(.height, toSize: 44)
        
        commitBtn.secret.pin(horizontal: 15)
        commitBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        commitBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        if case .unblock = type {
            return
        }
        

        let label = UILabel()
        label.text = "conversation.group.report.uploadPic".localized
        label.textColor = .dynamic(scheme: .title)
        label.font = UIFont(17, .medium)
        label.textAlignment = .left
        self.view.addSubview(label)
        label.frame = CGRect(x: 15, y: introTextV.frame.maxY + 30, width: 300, height: 20)
        
        self.photosView = SelectedPhotosView()
        self.photosView?.type = .three
        self.view.addSubview(self.photosView!)
        self.photosView?.frame = CGRect(x: 0, y: label.frame.maxY + 30, width: CGFloat.screenWidth, height: 140)
        self.photosView?.updateView(with: [])
        self.photosView!.responseClickAction = { [weak self] in
            guard let self = self else { return }
            var picker: YPImagePickerHelper? = nil
            picker = YPImagePickerHelper.init(type: .reportConversation, completionPick: { (items, isCancel) in
                picker!.dismissPicker()
                picker = nil
                if !isCancel {
                    self.chooseMediaItems = items.map({
                        return WRChooseMediaItem(items: $0)
                    })
                    self.photosView?.updateView(with: self.chooseMediaItems!)
                }
                self.updateCommitEnable()
            })
            picker!.presentPicker(by: self)
        }
        self.photosView!.responseDelIndex = {[weak self] index in
            guard let self = self else { return }
            self.chooseMediaItems?.remove(at: index)
            self.updateCommitEnable()
        }
        
    }
    
    @objc func commitAction() {
        guard !self.introTextV.text.isEmpty else { return }
        switch self.type {
        case .report:
            report()
        case .unblock:
            unblock()
        }
    }
    
    private func report() {
        guard let items = self.chooseMediaItems,
            items.count > 0,
            case .report(let typ) = self.type else { return }
        
        HUD.loading()
        
        var uploadPics: [String] = []
        let uploadFileGroup = DispatchGroup.init()
        for item in items {
            guard case .photo(let image, data: _) = item.type,
                let uploadData = image.compressionImageData() else { return }
            uploadFileGroup.enter()
            GroupReportService.fileUpload(file: uploadData) { (result) in
                switch result {
                case .success(let url):
                    uploadPics.append(url)
                case .failure(let err):
                    print(err)
                }
                uploadFileGroup.leave()
            }
        }

        uploadFileGroup.notify(queue: .main) {
            GroupReportService.report(cid: self.cid, typ: typ, photos: uploadPics, content: self.introTextV.text) { [weak self] (result) in
                HUD.hide()
                switch result {
                case .success:
                    let alert = UIAlertController.alertWithOKButton(
                    title: "conversation.group.report.reportSuccess".localized,
                    message: "") { _ in
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                    self?.present(alert, animated: true)
                case .failure(let err):
                    HUD.error(err)
                }
            }
        }
    }
    
    private func unblock() {
        HUD.loading()
        GroupReportService.unBlock(conversationId: self.cid, content: self.introTextV.text) { (result) in
            HUD.hide()
            switch result {
            case .success:
                AlertView(with: "conversation.group.report.commitSuccess".localized, confirm: AlertView.ActionType.confirm(("general.ok".localized, {[weak self] in
                    if self?.navigationController?.viewControllers.count == 1 {
                        self?.dismiss(animated: true, completion: nil)
                    } else {
                        self?.navigationController?.popToRootViewController(animated: true)
                    }
                })), cancel: nil).show()
            case .failure(let err):
                HUD.error(err)
            }
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.introTextV.resignFirstResponder()
        self.updateCommitEnable()
    }
    
    @objc func btnPlaceholdAction(sender: UIButton) {
        sender.isHidden = true
        introTextV.becomeFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholdBtn.isHidden = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count > 200 {
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count <= 200 {
            self.wordLimitlabel.text = "\(textView.text.count)/200"
        }
    }
    
    func updateCommitEnable() {
        var canCommit: Bool = false
        switch self.type {
        case .report:
            canCommit = !self.introTextV.text.isEmpty && self.chooseMediaItems?.count > 0
        case .unblock:
            canCommit = !self.introTextV.text.isEmpty
        }
        
        if canCommit {
            commitBtn.alpha = 1
            commitBtn.isUserInteractionEnabled = true
        } else {
            commitBtn.alpha = 0.6
            commitBtn.isUserInteractionEnabled = false
        }
    }
    
}
