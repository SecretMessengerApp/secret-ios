
import UIKit

class EmojjPreviewView: UIVisualEffectView {
    
    struct Action {
        var title: String
        var handler: () -> Void
    }
    
    init(url: String, contentFrame: CGRect = .zero, name: String = "") {
        self.contentFrame = contentFrame
        self.url = url
        self.name = name
        super.init(effect: UIBlurEffect(style: .regular))
        frame = UIScreen.main.bounds
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var contentFrame: CGRect = .zero
    private let url: String
    private let name: String
    
    private let imageView = AnimatedView()
    private let menuContainer = UIView()
    private var actions = [Action]()
    private var nameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 20)
        v.alpha = 0.0
        return v
    }()
    
    private let sepHeight: CGFloat = .hairline
    private let actionHeight: CGFloat = 56
    
    private var menusHeight: CGFloat {
        if actions.count == 0 {
            return 0
        }
        return actionHeight * CGFloat(actions.count) + CGFloat(actions.count - 1) * sepHeight
    }
    
    func addAction(title: String, handler: @escaping () -> Void) {
        self.actions.append(Action(title: title, handler: handler))
    }
    
    private func setup() {
        imageView.contentMode = .scaleAspectFit
        imageView.set(url, size: CGSize(width: 240, height: 240))
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(gesture)
        
        nameLabel.text = name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -80).isActive = true
    }
    
    private func playInAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
            self.alpha = 1.0
        }) { _ in
            // Do nothing
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear, animations: {
            self.imageView.center = self.center
            self.imageView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            self.menuContainer.transform = CGAffineTransform(translationX: 0, y: 0)
            self.nameLabel.alpha = 1.0
        }) { _ in
            // Do nothing
        }
    }
    
    private func playOutAction() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 0.0
        }) { _ in
            self.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveLinear, animations: {
            self.imageView.frame = self.contentFrame
            self.imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.menuContainer.transform = CGAffineTransform(translationX: 0, y: self.menusHeight)
            self.nameLabel.alpha = 0.0
        }) { _ in
            // Do nothing
        }
    }
    
    func show(window: UIWindow? = nil) {
        var targetWindow: UIWindow?
        if let win = window {
            targetWindow = win
        } else {
            targetWindow = UIApplication.shared.keyWindow
        }
        guard let twindow = targetWindow else {return}
        twindow.addSubview(self)
        imageView.frame = contentFrame
        setupMenu()
        playInAnimation()
    }
    
    @objc func dismiss() {
        playOutAction()
    }
    
    private func setupMenu() {
        guard actions.count > 0 else { return }
        
        let views: [UIView] = actions.map { action in
            let btn = UIButton()
            btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .medium)
            btn.setTitle(action.title, for: .normal)
            btn.setTitleColor(.dynamic(scheme: .brand), for: .normal)
            btn.backgroundColor = .dynamic(scheme: .cellBackground)
            btn.addAction(for: .touchUpInside) { [weak self] _ in
                self?.dismiss()
                action.handler()
            }
            return btn
        }
        
        let container = menuContainer
        container.backgroundColor = .dynamic(scheme: .separator)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.layer.cornerRadius = 16
        container.layer.masksToBounds = true
        contentView.addSubview(container)
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.spacing = .hairline
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stackView)
        
        let height = menusHeight
        let constraints = [
            container.heightAnchor.constraint(equalToConstant: height),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: 16)
        ] + stackView.edgesToSuperviewEdges()
        container.transform = CGAffineTransform(translationX: 0, y: height)
        NSLayoutConstraint.activate(constraints)
    }
}
