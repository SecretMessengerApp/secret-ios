
import UIKit
import SDWebImage
import SSticker

public final class ExpressionBarView: UIScrollView {
    
    public var tapIndexListener: ((Int) -> Void)?
    public var tapSettingListener: (() -> Void)?
    public var tapaddListener: (() -> Void)?
    
    private let containerView = UIView()
    private let stackView =  UIStackView()
    private let accentColor: UIColor = UIColor.accent()
    private let normalColor = UIColor.dynamic(scheme: .iconNormal)
    
    let favoriteButton          = IconButton()
    let historyButton           = IconButton()
    let addButton               = IconButton()
    let settingButton           = IconButton()
    
    private let lineView = UIView()
    
    public var buttons: [UIView] = [UIView]()
    
    private var buttonMargin: CGFloat {
        return conversationHorizontalMargins.left / 2 - StyleKitIcon.Size.tiny.rawValue / 2
    }
    
    deinit {
        ExpressionModel.shared.removeObserver(self)
    }
    
    required public init() {
        super.init(frame: CGRect.zero)
        self.showsHorizontalScrollIndicator = false
        self.bounces = false
        self.panGestureRecognizer.cancelsTouchesInView = true
        self.refreshButtons()
        ExpressionModel.shared.addExpressionZipChangedOberver(self, selector: #selector(ExpressionBarView.expressionZipChanged))
        ExpressionModel.shared.addRecentExpressionChangedOberver(self, selector: #selector(ExpressionBarView.recentZipChanged))
        ExpressionModel.shared.addFavoriteExpressionChangedOberver(self, selector: #selector(ExpressionBarView.favoriteZipChanged))
    }
    
    private func refreshButtons() {
        buttons.removeAll()
        self.subviews.forEach {$0.removeFromSuperview()}
        stackView.subviews.forEach {$0.removeFromSuperview()}
        buttons = []
        if LocalExpressionStore.favorite.getAllData().count > 0 {
            buttons.append(favoriteButton)
        }
        if LocalExpressionStore.recent.getAllData().count > 0 {
            buttons.append(historyButton)
        }
        let localZips = ExpressionModel.shared.getSecretExpressions()
        for zip in localZips {
            let localExpressionButton = IconButton()
            localExpressionButton.widthAnchor.constraint(equalToConstant: 35).isActive = true
            localExpressionButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
            localExpressionButton.sd_setImage(with: URL(string: zip.icon), for: .normal, placeholderImage: nil, options: .retryFailed, completed: nil)
            localExpressionButton.tag = zip.id
            localExpressionButton.addTarget(self, action: #selector(ExpressionBarView.tapExpression), for: .touchUpInside)
            buttons.append(localExpressionButton)
        }
        
        let remoteZips = ExpressionModel.shared.getMyExpressionZips()
        for zip in remoteZips {
            let tgsImageView = StickerAnimatedImageView(frame: .zero)
            tgsImageView.isUserInteractionEnabled = true
            tgsImageView.widthAnchor.constraint(equalToConstant: 35).isActive = true
            tgsImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
            if let u = URL(string: zip.icon) {
               tgsImageView.setSecretAnimation(u, CGSize(width: 70, height: 70), nil, true)
            }
            tgsImageView.tag = zip.id
            let tap = UITapGestureRecognizer(target: self, action: #selector(ExpressionBarView.tapTgsSticker))
            tgsImageView.addGestureRecognizer(tap)
            buttons.append(tgsImageView)
        }
        buttons += [
            addButton,
            settingButton
        ]
        
        let setCornerRadius: (UIView)->Void = { v in
            v.layer.cornerRadius = 8
            v.layer.masksToBounds = true
        }
        
        buttons.forEach { (v)  in
            setCornerRadius(v)
        }
        setCornerRadius(favoriteButton)
        setCornerRadius(historyButton)
        if buttons.count > 0 {
            self.selectButton(buttons[0])
        }
        setupViews()
        setupActions()
    }
    
    @objc func expressionZipChanged() {
        refreshButtons()
    }
    
    @objc func favoriteZipChanged() {
        if LocalExpressionStore.favorite.getAllData().count == 0 {
            if buttons.contains(favoriteButton) {
                buttons.remove(at: buttons.firstIndex(of: favoriteButton)!)
                self.stackView.removeArrangedSubview(favoriteButton)
            }
            favoriteButton.isHidden = true
        } else {
            if !buttons.contains(favoriteButton) {
                buttons.insert(favoriteButton, at: 0)
                self.stackView.insertArrangedSubview(favoriteButton, at: 0)
            }
            self.deSelectButton(favoriteButton)
            favoriteButton.isHidden = false
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    @objc func recentZipChanged() {
        if LocalExpressionStore.recent.getAllData().count == 0 {
            if buttons.contains(historyButton) {
                buttons.remove(at: buttons.firstIndex(of: historyButton)!)
                self.stackView.removeArrangedSubview(historyButton)
                historyButton.isHidden = true
            }
        } else {
            if !buttons.contains(historyButton) {
                if buttons.contains(favoriteButton) {
                    buttons.insert(historyButton, at: 1)
                    self.stackView.insertArrangedSubview(historyButton, at: 1)
                } else {
                    buttons.insert(historyButton, at: 0)
                    self.stackView.insertArrangedSubview(historyButton, at: 0)
                }
            }
            self.deSelectButton(historyButton)
            historyButton.isHidden = false
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    
    func selectIndex(_ index: Int) {
        if index < buttons.count {
            let button = buttons[index]
            self.selectButton(button)
        }
    }

    func setupActions() {
        favoriteButton.addTarget(self, action: #selector(ExpressionBarView.tapExpression), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(ExpressionBarView.tapHistory), for: .touchUpInside)
        settingButton.addTarget(self, action: #selector(ExpressionBarView.tapSetting), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(ExpressionBarView.tapAdd), for: .touchUpInside)
    }
    
    @objc func tapFavorite(_ sender: IconButton) {
        selectButton(sender)
        guard let index = self.buttons.firstIndex(of: sender) else {return}
        self.tapIndexListener?(index)
    }
    
    @objc func tapHistory(_ sender: IconButton) {
        selectButton(sender)
        guard let index = self.buttons.firstIndex(of: sender) else {return}
        self.tapIndexListener?(index)
    }
    
    @objc func tapExpression(_ sender: IconButton) {
        selectButton(sender)
        guard let index = self.buttons.firstIndex(of: sender) else {return}
        self.tapIndexListener?(index)
    }
    
    @objc func tapAdd(_ sender: IconButton) {
        selectButton(sender)
        self.tapaddListener?()
    }
    
    @objc func tapSetting(_ sender: IconButton) {
        selectButton(sender)
        self.tapSettingListener?()
    }
    
    @objc func tapTgsSticker(tap: UITapGestureRecognizer) {
        guard let v = tap.view else {return}
        selectButton(v)
        guard let index = self.buttons.firstIndex(of: v) else {return}
        self.tapIndexListener?(index)
    }
    
    private func selectButton(_ view: UIView) {
        defer {
            buttons.forEach { $0.backgroundColor = .clear }
            view.backgroundColor = UIColor.init(hex: 0xE0E1E4)
        }
        let leftOffset = view.frame.maxX - UIScreen.main.bounds.size.width
        if  leftOffset > 0 && self.contentOffset.x < leftOffset {
            self.setContentOffset(CGPoint(x: leftOffset + 10, y: 0), animated: false)
            return
        }
        let rightOffset = view.frame.minX - self.contentOffset.x
        if rightOffset < 0 {
            self.setContentOffset(CGPoint(x: view.frame.minX - 20, y: 0), animated: false)
        }
    }
    
    private func deSelectButton(_ view: UIView) {
        view.backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 56)
    }
    
    private func setupViews() {
        
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 36
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: buttonMargin, bottom: 0, right: buttonMargin)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        favoriteButton.setImage(UIImage.init(named: "inputbar_expression_favorite"), for: .normal)
        historyButton.setImage(UIImage.init(named: "inputbar_expression_history"), for: .normal)
        addButton.setImage(UIImage.init(named: "inputbar_expression_add"), for: .normal)
        settingButton.setImage(UIImage.init(named: "inputbar_expression_setting"), for: .normal)
        
        for button in buttons {
            stackView.addArrangedSubview(button)
        }
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        addSubview(stackView)
        
        lineView.backgroundColor = .dynamic(scheme: .separator)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lineView)
        
        var constraints = [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leftAnchor.constraint(equalTo: leftAnchor),
            containerView.rightAnchor.constraint(equalTo: rightAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        constraints += [
            stackView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 55),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -1)
        ]
        constraints += [
            lineView.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude),
            lineView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            lineView.heightAnchor.constraint(equalToConstant: .hairline)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
}


