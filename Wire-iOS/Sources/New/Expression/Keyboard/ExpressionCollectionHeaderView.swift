
import UIKit

class ExpressionCollectionHeaderView: UICollectionReusableView {
    
    public var needReloadListener: (()-> Void)?
    private var zip: ExpressionZip?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        self.addSubview(deleteButton)
        self.createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setZip(zip: ExpressionZip) {
        self.zip = zip
        self.titleLabel.text = zip.name
        self.deleteButton.isHidden = !(zip.isRecent && zip.gifs.count > 0)
    }
    
    @objc func deleteExpression() {
        guard let z = self.zip, z.isRecent else {return}
        LocalExpressionStore.recent.removeAllData()
        ExpressionModel.shared.postRecentExpressionChanged()
        self.needReloadListener?()
    }
    
    func createConstraints() {
        var constraints = [
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16)
        ]
        constraints += [
            deleteButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 10),
            deleteButton.heightAnchor.constraint(equalToConstant: 10)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .dynamic(scheme: .note)
        return label
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "servicemessagecancel"), for: .normal)
        button.addTarget(self, action: #selector(ExpressionCollectionHeaderView.deleteExpression), for: .touchUpInside)
        return button
    }()
}
