

import Foundation

class ScanToolsbar: UIView {
    
    public var selectListener: ((Int) -> Void)?
    public var clickable: Bool = true {
        didSet {
            if clickable {
                self.qrButton.isUserInteractionEnabled = true
            } else {
                self.qrButton.isUserInteractionEnabled = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        [qrButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        self.addSubview(qrButton)
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        
        let constraints = [
            qrButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            qrButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            qrButton.widthAnchor.constraint(equalToConstant: 40),
            qrButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc func qrtap() {
        self.qrButton.isSelected = true
        self.selectListener?(0)
    }
    
    private lazy var qrButton: UIButton = {
        let btn = self.generateButton(title: "conversation.popover.detail.scan".localized, sImg: "qrselected", img: "qrdeselected")
        btn.addTarget(self, action: #selector(ScanToolsbar.qrtap), for: .touchUpInside)
        btn.isSelected = true
        return btn
    }()
    
    func generateButton(title: String, sImg: String, img: String) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.init(named: img), for: .normal)
        btn.setImage(UIImage.init(named: sImg), for: .selected)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(.dynamic(scheme: .brand), for: .selected)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -32, bottom: -30, right: 0)
        btn.imageEdgeInsets = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return btn
    }
    
}
