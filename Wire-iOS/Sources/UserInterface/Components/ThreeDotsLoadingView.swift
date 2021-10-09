

import UIKit
import Foundation
import Cartography

final class ThreeDotsLoadingView: UIView {
    
    private let loadingAnimationKey = "loading"
    private let dotRadius = 2
    private var activeColor: UIColor {
        .dynamic(scheme: .loadingDotActive)
    }
    private var inactiveColor: UIColor {
        .dynamic(scheme: .loadingDotInactive)
    }
    
    private let dot1 = UIView()
    private let dot2 = UIView()
    private let dot3 = UIView()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(dot1)
        addSubview(dot2)
        addSubview(dot3)
        
        setupViews()
        setupConstraints()
        startProgressAnimation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ThreeDotsLoadingView.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func setupViews() {
        [dot1, dot2, dot3].forEach { (dot) in
            dot.layer.cornerRadius = CGFloat(dotRadius);
            dot.backgroundColor = .dynamic(scheme: .loadingDotInactive)
        }
    }
    
    @objc func setupConstraints() {
        
        constrain(self, dot1, dot3) { container, leadingDot, trailingDot in
            leadingDot.left == container.left
            trailingDot.right == container.right
        }
        
        [dot1, dot2, dot3].forEach { (dot) in
            constrain(self, dot) { container, dot in
                dot.top == container.top
                dot.bottom == container.bottom
                dot.width == CGFloat(dotRadius * 2)
                dot.height == CGFloat(dotRadius * 2)
            }
        }
        
        constrain(dot1, dot2, dot3) { dot1, dot2, dot3 in
            distribute(by: 4, horizontally: dot1, dot2, dot3)
        }
    }
    
    override var isHidden: Bool{
        didSet {
            updateLoadingAnimation()
        }
    }
    
    @objc func updateLoadingAnimation() {
        if (isHidden) {
            stopProgressAnimation()
        } else {
            startProgressAnimation()
        }
    }
    
    @objc func startProgressAnimation() {
        let stepDuration = 0.350
        let colorShift = CAKeyframeAnimation(keyPath: "backgroundColor")
        if #available(iOS 13.0, *) {
            traitCollection.performAsCurrent {
                colorShift.values = [
                    activeColor.cgColor,
                    inactiveColor.cgColor,
                    inactiveColor.cgColor,
                    activeColor.cgColor
                ]
            }
        } else {
            colorShift.values = [
                activeColor.cgColor,
                inactiveColor.cgColor,
                inactiveColor.cgColor,
                activeColor.cgColor
            ]
        }
        colorShift.keyTimes = [0, 0.33, 0.66, 1]
        colorShift.duration = 4 * stepDuration
        colorShift.repeatCount = Float.infinity
        colorShift.speed = -1;
        
        
        let colorShift1 = colorShift.copy() as! CAKeyframeAnimation
        colorShift1.timeOffset = 0
        dot1.layer.add(colorShift1, forKey: loadingAnimationKey)
        
        let colorShift2 = colorShift.copy()  as! CAKeyframeAnimation
        colorShift2.timeOffset = 1 * stepDuration
        dot2.layer.add(colorShift2, forKey: loadingAnimationKey)
        
        let colorShift3 = colorShift.copy()  as! CAKeyframeAnimation
        colorShift3.timeOffset = 2 * stepDuration
        dot3.layer.add(colorShift3, forKey: loadingAnimationKey)
    }
    
    @objc func stopProgressAnimation() {
        [dot1, dot2, dot3].forEach { $0.layer.removeAnimation(forKey: loadingAnimationKey) }
    }

}

extension ThreeDotsLoadingView {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLoadingAnimation()
    }
}

extension ThreeDotsLoadingView {
    @objc func applicationDidBecomeActive(_ notification : Notification) {
        updateLoadingAnimation()
    }
}
