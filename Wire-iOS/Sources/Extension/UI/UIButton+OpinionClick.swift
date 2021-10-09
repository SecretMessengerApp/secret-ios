//
//  UIButton+OpinionClick.swift
//  Wire-iOS
//


import UIKit
import CoreAudioKit

private var oldTimeTag: Int = 0
private var interfTag: Int = 2
private var hasAddTargetTag: Int = 3
private var opinionClickTag: Int = 4
private var isOpinionTag: Int = 5
private var explosionLayerTag: Int = 6
private var explosionCellTag: Int = 7
private var canOptionClick: Int = 8

private let DEFAULT_INTERF: TimeInterval = 0.6

extension UIButton {

    var oldTime: TimeInterval {
        get {
            if let oldTime = objc_getAssociatedObject(self, &oldTimeTag) as? TimeInterval {
                return oldTime
            }
            return 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &oldTimeTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    var interf: TimeInterval {
        get {
            if let interf = objc_getAssociatedObject(self, &interfTag) as? TimeInterval {
                return interf
            }
            return 0
        }
        set(newValue) {
            objc_setAssociatedObject(self, &interfTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    var isopinion: Bool {
        get {
            if let isopion = objc_getAssociatedObject(self, &isOpinionTag) as? Bool {
                return isopion
            }
            return false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &isOpinionTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var explosionLayer: CAEmitterLayer? {
        get {
            if let explosionLayer = objc_getAssociatedObject(self, &explosionLayerTag) as? CAEmitterLayer {
                return explosionLayer
            }
            return nil
        }
        set(newValue) {
            objc_setAssociatedObject(self, &explosionLayerTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var explosionCell: CAEmitterCell? {
        get {
            if let explosionCell = objc_getAssociatedObject(self, &explosionCellTag) as? CAEmitterCell {
                return explosionCell
            }
            return nil
        }
        set(newValue) {
            objc_setAssociatedObject(self, &explosionCellTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    

    var hasAddTarget: Bool {
        get {
            if let hasAddTarget = objc_getAssociatedObject(self, &hasAddTargetTag) as? Bool {
                return hasAddTarget
            }
            return false
        }
        set(newValue) {
            objc_setAssociatedObject(self, &hasAddTargetTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    var opinionClick: ((Bool) -> Void)? {
        get {
            if let singleClick = objc_getAssociatedObject(self, &opinionClickTag) as? (Bool) -> Void {
                return singleClick
            }
            return nil
        }

        set(newValue) {
            if !self.hasAddTarget {
                self.addTarget(self, action: #selector(UIButton.clickBtn), for: .touchUpInside)
                self.addTarget(self, action: #selector(UIButton.allEvent), for: .allEvents)
                self.hasAddTarget = true
            }

            objc_setAssociatedObject(self, &opinionClickTag, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    public var isClick: Bool {
        get {
            if let flag = objc_getAssociatedObject(self, &canOptionClick) as? Bool {
                return flag
            }
            return true
        }
        set(newValue) {
            objc_setAssociatedObject(self, &canOptionClick, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @objc fileprivate func clickBtn() {
        self.isHighlighted = false
        if isClick == false {return}
        let currentTime = CACurrentMediaTime()
        if  isopinion && currentTime - self.oldTime > interf {
            isopinion = false
            opinionClick?(isopinion)
            oldTime = currentTime
            explosionAni()
        } else if !isopinion {
            isopinion = true
            opinionClick?(isopinion)
            oldTime = currentTime
            explosionAni()
        }
    }
    
    @objc fileprivate func allEvent() {
        self.isHighlighted = false
    }

    func setOnSingleOpinionClickListener(_ interf: TimeInterval, _ listener: @escaping (Bool) -> Void) {
        self.adjustsImageWhenDisabled = false
        self.adjustsImageWhenHighlighted = false
        self.explosionLayer = CAEmitterLayer.init()
        self.setupExplosion()
        self.interf = interf
        self.opinionClick = listener
    }
    
    
    func setupExplosion() {
        
        self.explosionCell = CAEmitterCell.init()
        
        explosionCell?.name = "explosion"
        explosionCell?.alphaRange = 0.10
        explosionCell?.alphaSpeed = -1.0
        explosionCell?.lifetime = 0.7
        explosionCell?.lifetimeRange = 0.3
        explosionCell?.birthRate = 2500
        explosionCell?.velocity = 40.00

        explosionCell?.velocityRange = 10.00
        

        explosionCell?.scale = 0.03

        explosionCell?.scaleRange = 0.02

        explosionCell?.contents = UIImage(named: "sparkle")?.cgImage
        
        explosionLayer?.name = "explosionLayer"

        explosionLayer?.emitterShape = CAEmitterLayerEmitterShape.sphere

        explosionLayer?.emitterMode = CAEmitterLayerEmitterMode.outline
    
        explosionLayer?.emitterSize = CGSize.init(width: 10, height: 0)

        explosionLayer?.emitterCells = [self.explosionCell!]

        explosionLayer?.renderMode = CAEmitterLayerRenderMode.oldestFirst
        explosionLayer?.masksToBounds = false
        explosionLayer?.birthRate = 0

        explosionLayer?.position = CGPoint.init(x: 10, y: 10)
        explosionLayer?.zPosition = -1
        self.imageView?.layer.addSublayer(explosionLayer!)
        self.imageView?.layer.masksToBounds = false
    }

    func explosionAni() {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        if isopinion {
            animation.values = [1.5, 0.8, 1.0, 1.2, 1.0]
            animation.duration = 0.5
            startAnimation()
            var soundID: SystemSoundID = 0

            let path = Bundle.main.path(forResource: "click_like", ofType: "wav")
            if let pa = path {
     
                let baseURL = NSURL(fileURLWithPath: pa)
    
                AudioServicesCreateSystemSoundID(baseURL, &soundID)
    
                AudioServicesPlaySystemSound(soundID)
                
                WRTools.shake()
            }
        } else {
            animation.values = [0.8, 1.0]
            animation.duration = 0.4
        }
        animation.calculationMode = CAAnimationCalculationMode.cubic
        layer.add(animation, forKey: "transform.scale")
    }
    
    func startAnimation() {
        explosionLayer?.beginTime = CACurrentMediaTime()
        explosionLayer?.birthRate = 1
        perform(#selector(UIButton.stopAnimation), with: nil, afterDelay: 0.15)
    }
    
    @objc func stopAnimation() {
        explosionLayer?.birthRate = 0
    }

}
