
import UIKit

class EmojjCell: UITableViewCell {
    let iconView = AnimatedView()
    let titleView = UILabel()
    let subtitleView = UILabel()
    let markView = UIButton()
    
    var middleStack: UIStackView!
    var stack: UIStackView!
    
    var onMarkViewClicked: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .dynamic(scheme: .cellBackground)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        middleStack = UIStackView(arrangedSubviews: [titleView, subtitleView])
        middleStack.axis = .vertical
        middleStack.distribution = .equalCentering
        
        stack = UIStackView(arrangedSubviews: [iconView, middleStack, .flexible(), markView])
        stack.axis = .horizontal
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        
        titleView.font = FontSpec(.normal, .medium).font
        titleView.textColor = .dynamic(scheme: .title)
        subtitleView.font = FontSpec(.small, .regular).font
        subtitleView.textColor = .dynamic(scheme: .subtitle)
        
        contentView.addSubview(stack)
        iconView.contentMode = .scaleAspectFit
        iconView.isHidden = true
        subtitleView.isHidden = true
        
        markView.isHidden = true
        markView.addTarget(self, action: #selector(btnMarkClicked), for: .touchUpInside)
        markView.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 0)
    }
    
    @objc func btnMarkClicked() {
        self.onMarkViewClicked?()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 40),
            iconView.heightAnchor.constraint(equalTo: iconView.widthAnchor, multiplier: 1.0),
//            iconView.centerYAnchor.constraint(equalTo: stack.centerYAnchor),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -9),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15)
        ])
    }
    
    func update(icon: UIImage?) {
        fatalError("=====")
    }
    
    func update(icon: String?) {
        if let icon = icon {
            self.iconView.isHidden = false
            self.iconView.set(icon, size: CGSize(width: 80, height: 80))
        } else {
            self.iconView.isHidden = true
        }
    }
    
    func update(title: String?) {
        self.titleView.text = title
    }
    
    func update(subtitle: String?) {
        self.subtitleView.text = subtitle
        self.subtitleView.isHidden = subtitle == nil
    }
    
    func update(mark: String?) {
        if let icon = mark {
            self.markView.setImage(UIImage(named: icon), for: .normal)
        }
        self.markView.isHidden = mark == nil
    }
}

private extension UIView {
    static func flexible() -> UIView {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        v.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        v.setContentHuggingPriority(.defaultLow, for: .vertical)
        v.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return v
    }
}
