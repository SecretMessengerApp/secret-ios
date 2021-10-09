
import UIKit
import Cartography


final class AnimatedPenView : UIView {
    
    private let WritingAnimationKey = "writing"
    private let dots = UIImageView()
    private let pen = UIImageView()
    
    var isAnimating : Bool = false {
        didSet {
            pen.layer.speed = isAnimating ? 1 : 0
            pen.layer.beginTime = pen.layer.convertTime(CACurrentMediaTime(), from: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateIconColor()
        pen.contentMode = .center

        addSubview(dots)
        addSubview(pen)
        
        setupConstraints()
        startWritingAnimation()
        
        pen.layer.speed = 0
        pen.layer.timeOffset = 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateIconColor() {
        let iconColor = UIColor.dynamic(scheme: .iconNormal)
        dots.setIcon(.typingDots, size: 8, color: iconColor)
        pen.setIcon(.pencil, size: 8, color: iconColor)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        userInterfaceStyleDidChange(previousTraitCollection) { [weak self] _ in
            self?.updateIconColor()
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        startWritingAnimation()
    }
    
    func setupConstraints() {
        constrain(self, dots, pen) { container, dots, pen in
            distribute(by: 2, horizontally: dots, pen)
            
            dots.left == container.left
            dots.top == container.top
            dots.bottom == container.bottom
            
            pen.right == container.right
            pen.top == container.top
            pen.bottom == container.bottom
        }
    }
    
    func startWritingAnimation() {
        
        let p1 = 7
        let p2 = 10
        let p3 = 13
        let moveX = CAKeyframeAnimation(keyPath: "position.x")
        moveX.values = [p1, p2, p2, p3, p3, p1]
        moveX.keyTimes = [0, 0.25, 0.35, 0.50, 0.75, 0.85]
        moveX.duration = 2
        moveX.repeatCount = Float.infinity
        
        pen.layer.add(moveX, forKey: WritingAnimationKey)
    }
    
    func stopWritingAnimation() {
        pen.layer.removeAnimation(forKey: WritingAnimationKey)
    }
    
    @objc func applicationDidBecomeActive(_ notification : Notification) {
        startWritingAnimation()
    }

}

 class TypingIndicatorView: UIView {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .smallLightFont
        label.textColor = .dynamic(scheme: .iconNormal)
        return label
    }()
    let animatedPen = AnimatedPenView()
    let container: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .secondaryBackground)
        return view
    }()
    let expandingLine: UIView = {
        let view = UIView()
        view.backgroundColor = .dynamic(scheme: .background)
        return view
    }()

    private var expandingLineWidth : NSLayoutConstraint?
    
    var typingUsers : [ZMUser] = [] {
        didSet {
            updateNameLabel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(expandingLine)
        addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(animatedPen)
                
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        container.layer.cornerRadius = container.bounds.size.height / 2
    }
    
    func setupConstraints() {
        constrain(self, container, nameLabel, animatedPen, expandingLine) { view, container, nameLabel, animatedPen, expandingLine in
            container.edges == view.edges
            
            distribute(by: 4, horizontally: animatedPen, nameLabel)
            
            animatedPen.left == container.left + 8
            animatedPen.centerY == container.centerY
            
            nameLabel.top == container.top + 4
            nameLabel.bottom == container.bottom - 4
            nameLabel.right == container.right - 8
            
            expandingLine.center == view.center
            expandingLine.height == 1
            expandingLineWidth = expandingLine.width == 0
        }
    }
    
    func updateNameLabel() {
        nameLabel.text = typingUsers.map { ($0.reMark ?? $0.displayName).uppercased(with: .current) }.joined(separator: ", ")
    }
    
    func setHidden(_ hidden : Bool, animated : Bool) {
        
        let collapseLine = { () -> Void in
            self.expandingLineWidth?.constant = 0
            self.layoutIfNeeded()
        }
        
        let expandLine = { () -> Void in
            self.expandingLineWidth?.constant = self.bounds.width
            self.layoutIfNeeded()
        }
        
        let showContainer = {
            self.container.alpha = 1
        }
        
        let hideContainer = {
            self.container.alpha = 0
        }
        
        if (animated) {
            if (hidden) {
                collapseLine()
                UIView.animate(withDuration: 0.15, animations: hideContainer)
            } else {
                animatedPen.isAnimating = false
                self.layoutSubviews()
                UIView.animate(easing: .easeInOutQuad, duration: 0.35, animations: expandLine)
                UIView.animate(easing: .easeInQuad, duration: 0.15, delayTime: 0.15, animations: showContainer) { _ in
                    self.animatedPen.isAnimating = true
                }
            }
            
        } else {
            if (hidden) {
                collapseLine()
                self.container.alpha = 0
            } else {
                expandLine()
                showContainer()
            }
        }
    }
    
}
