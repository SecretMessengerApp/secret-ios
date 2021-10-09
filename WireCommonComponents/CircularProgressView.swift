

import Foundation
import UIKit

public class CircularProgressView: UIView {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        setupShapeLayer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(CircularProgressView.applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    fileprivate func setupShapeLayer() {
        self.createPath()
        self.shapeLayer.lineWidth = CGFloat(lineWidth)
        self.shapeLayer.lineCap = lineCap
        self.shapeLayer.strokeStart = 0.0
        self.shapeLayer.strokeEnd = CGFloat(self.progress)
        self.shapeLayer.fillColor = UIColor.clear.cgColor
        self.shapeLayer.strokeColor = self.tintColor.cgColor
    }
    
    override public func didMoveToWindow() {
        updateSpinningAnimation()
    }
    
    override public var tintColor: UIColor! {
        didSet {
            shapeLayer.strokeColor = tintColor.cgColor
        }
    }
    
    public var lineCap: CAShapeLayerLineCap = .square {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var lineWidth : Float = 2 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var deterministic : Bool = true {
        didSet {
            updateSpinningAnimation()
        }
    }
    
    fileprivate func createPath() {
        self.shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.width/2).cgPath
    }
    
    override public class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    
    var shapeLayer: CAShapeLayer {
        get {
            if let shapeLayer = self.layer as? CAShapeLayer {
                return shapeLayer
            }
            fatalError("shapeLayer is missing: \(self.layer)")
        }
    }
    
    fileprivate(set) var progress : Float = 0.0
        
    public func setProgress(_ progress: Float, animated: Bool) {
        self.progress = progress
        
        if (animated) {
            let stroke = CABasicAnimation(keyPath: "strokeEnd")
            stroke.fromValue = self.shapeLayer.strokeEnd
            stroke.toValue = progress
            stroke.duration = 0.35
            stroke.fillMode = .forwards
            
            self.shapeLayer.add(stroke, forKey: nil)
        } else {
            let stroke = CABasicAnimation(keyPath: "strokeEnd")
            stroke.fromValue = CGFloat(progress)
            self.shapeLayer.add(stroke, forKey: nil)
        }
        
        CATransaction.setDisableActions(true)
        self.shapeLayer.strokeEnd = CGFloat(progress)
        CATransaction.setDisableActions(false)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupShapeLayer()
    }
    
    // MARK: - Spinning animation
    
    let SpinningAnimationKey = "com.wire.animations.spin"
    
    fileprivate func updateSpinningAnimation() {
        if !deterministic {
            startSpinningAnimation()
        } else {
            stopSpinningAnimation()
        }
    }
    
    fileprivate func startSpinningAnimation() {
        let rotate = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotate.fillMode = .forwards
        rotate.toValue = 2 * CGFloat.pi
        rotate.repeatCount = .infinity
        rotate.duration = 1.0
        rotate.isCumulative = true
        rotate.timingFunction = CAMediaTimingFunction(name: .linear)
        
        self.shapeLayer.add(rotate, forKey: SpinningAnimationKey);
    }
    
    fileprivate func stopSpinningAnimation() {
        self.shapeLayer.removeAnimation(forKey: SpinningAnimationKey)
    }
}

extension CircularProgressView {
    @objc func applicationDidBecomeActive(_ notification : Notification) {
        updateSpinningAnimation()
    }
}
