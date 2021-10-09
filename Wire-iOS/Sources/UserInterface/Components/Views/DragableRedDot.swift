

import UIKit

public class DragableRedDot: UIView {
    
    enum AdhesivePlateStatus {
        case stickers
        case separate
    }
    
    typealias SeparateClosure = ((UIView?) -> Bool)
    
    let maxDistance: CGFloat = 60
    let bubbleColor: UIColor = .vividRed
    var prototypeView: UIImageView = UIImageView()
    var separateClosureDictionary: NSMutableDictionary = NSMutableDictionary()

    var touchView: UIView?
    var deviationPoint: CGPoint = .zero
    var shapeLayer: CAShapeLayer?
    var bubbleWidth: CGFloat = 0
    
    var centerDistance: CGFloat = 0
    var oldBackViewCenter: CGPoint = .zero
    var fillColorForCute: UIColor = .red
    var sStatus: AdhesivePlateStatus = .separate
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func attach(item: UIView, With separateClosure: SeparateClosure?) {
        let viewValue: NSValue = NSValue(nonretainedObject: item)
        
        if separateClosureDictionary[viewValue] == nil {
            let panG = UIPanGestureRecognizer(target: self, action: #selector(handlerPanGesture(_ :)))
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(panG)
        }
        if separateClosure != nil {
            separateClosureDictionary.setObject(separateClosure!, forKey: viewValue)
        } else {
            let closure: SeparateClosure = { UIView in  return false }
            separateClosureDictionary.setObject(closure, forKey: viewValue)
        }
        
    }
    
    
    @objc func handlerPanGesture(_  pan: UIPanGestureRecognizer) {
        let dragPoint: CGPoint = pan.location(in: self)
        
        if pan.state == .began {
            touchView = pan.view
            let dragPontInView = pan.location(in: pan.view)
            deviationPoint = CGPoint(x: dragPontInView.x - (pan.view?.frame.size.width ?? 0) / 2, y: dragPontInView.y - (pan.view?.frame.size.height ?? 0) / 2)
            
            setUp()
        } else if pan.state == .changed {
            prototypeView.center = CGPoint(x: dragPoint.x - deviationPoint.x, y: dragPoint.y - deviationPoint.y)
            drawRect()
        } else if pan.state == .ended || pan.state == .cancelled || pan.state == .failed {
          
            if centerDistance > maxDistance {
                
                let value = NSValue(nonretainedObject: touchView)
                if let closure = separateClosureDictionary.object(forKey: value) as? SeparateClosure {
                    let animationBool = closure(touchView)
                    if animationBool {
                        prototypeView.removeFromSuperview()
//                        explosion(centerPint: prototypeView.center, radius: bubbleWidth)
                        touchView?.isHidden = true
                        self.removeFromSuperview()
                    } else {
                        springBack(view: prototypeView, point: oldBackViewCenter)
                    }
                }
            } else {
                fillColorForCute = .clear
                shapeLayer?.removeFromSuperlayer()
                springBack(view: prototypeView, point: oldBackViewCenter)
            }
        }
    }
    
    
    func setUp() {
        guard let wd = UIApplication.shared.delegate?.window else { return }
        wd?.addSubview(self)
        let animationViewOrigin = touchView?.convert(CGPoint(x: 0, y: 0), to: self)
        
        prototypeView.frame = CGRect(x: (animationViewOrigin?.x)!, y: (animationViewOrigin?.y)!, width: (touchView?.frame.size.width)!, height: (touchView?.frame.size.height)!)
        prototypeView.image = getImageFrom(touchView!)
        self.addSubview(prototypeView)
        
        shapeLayer = CAShapeLayer()
        bubbleWidth = min(prototypeView.frame.size.width, prototypeView.frame.size.height) - 1
        
        centerDistance = 0
        oldBackViewCenter = CGPoint(x: (animationViewOrigin?.x)! + (touchView?.frame.size.width)! / 2, y: (animationViewOrigin?.y)! + (touchView?.frame.size.height)! / 2)
        
        
        fillColorForCute = bubbleColor
        
        touchView?.isHidden = true
        self.isUserInteractionEnabled = true
        self.sStatus = .stickers
    }
    
    
    func drawRect() {
        let X1 = oldBackViewCenter.x
        let Y1 = oldBackViewCenter.y
        let X2 = prototypeView.center.x
        let Y2 = prototypeView.center.y
        
        let ax: CGFloat = (X2 - X1) * (X2 - X1)
        let ay: CGFloat = (Y2 - Y1) * (Y2 - Y1)
        
        centerDistance = CGFloat( sqrtf( Float( ax + ay) ))
        if (sStatus == .separate) {
            return
        }
        
        if centerDistance > maxDistance {
            sStatus = .separate
            fillColorForCute = .clear
            shapeLayer?.removeFromSuperlayer()
            return
        }
        var cosDigree: CGFloat = 0          
        var sinDigree: CGFloat = 0
        if centerDistance == 0 {
            cosDigree = 1
            sinDigree = 0
        } else {
            cosDigree = (Y2 - Y1) / centerDistance
            sinDigree = (X2 - X1) / centerDistance
        }
        
        let percentage = centerDistance / maxDistance
        let R1 = (2 - percentage / 2) * bubbleWidth / 5
        let R2 = bubbleWidth / 2
        var offset1 = R1 * 2 / 3.6
        var offset2 = R2 * 2 / 3.6
        
        let pointA = CGPoint(x: X1 - R1 * cosDigree, y: Y1 + R1 * sinDigree)
        let pointB = CGPoint(x: X1 + R1 * cosDigree, y: Y1 - R1 * sinDigree)
        let pointE = CGPoint(x: X1 - R1 * sinDigree, y: Y1 - R1 * cosDigree)
        let pointC = CGPoint(x: X2 + R2 * cosDigree, y: Y2 - R2 * sinDigree)
        let pointD = CGPoint(x: X2 - R2 * cosDigree, y: Y2 + R2 * sinDigree)
        let pointF = CGPoint(x: X2 + R2 * sinDigree, y: Y2 + R2 * cosDigree)
        
        let pointEA2 = CGPoint(x: pointA.x - offset1*sinDigree, y: pointA.y - offset1*cosDigree)
        let pointEA1 = CGPoint(x: pointE.x - offset1*cosDigree, y: pointE.y + offset1*sinDigree)
        let pointBE2 = CGPoint(x: pointE.x + offset1*cosDigree, y: pointE.y - offset1*sinDigree)
        let pointBE1 = CGPoint(x: pointB.x - offset1*sinDigree, y: pointB.y - offset1*cosDigree)
        
        let pointFC2 = CGPoint(x: pointC.x + offset2*sinDigree, y: pointC.y + offset2*cosDigree)
        let pointFC1 = CGPoint(x: pointF.x + offset2*cosDigree, y: pointF.y - offset2*sinDigree)
        let pointDF2 = CGPoint(x: pointF.x - offset2*cosDigree, y: pointF.y + offset2*sinDigree)
        let pointDF1 = CGPoint(x: pointD.x + offset2*sinDigree, y: pointD.y + offset2*cosDigree)
        
        let pointTemp = CGPoint(x: pointD.x + percentage*(X2 - pointD.x), y: pointD.y + percentage*(Y2 - pointD.y))
        let tempX = (2 - percentage)*(X2 - pointD.x)
        let tempY = (2 - percentage)*(Y2 - pointD.y)
        let pointTemp2 = CGPoint(x: pointD.x + tempX, y: pointD.y + tempY)
        
        let pointO = CGPoint(x: pointA.x + (pointTemp.x - pointA.x)/2, y: pointA.y + (pointTemp.y - pointA.y)/2)
        let pointP = CGPoint(x: pointB.x + (pointTemp2.x - pointB.x)/2, y: pointB.y + (pointTemp2.y - pointB.y)/2)
        
        offset1 = centerDistance/8
        offset2 = centerDistance/8
        

        let pointAO1 = CGPoint(x: pointA.x + offset1*sinDigree, y: pointA.y + offset1*cosDigree);
        
        let tempSinDigree = (3*offset2-offset1)*sinDigree
        let tempCosDigree = (3*offset2-offset1)*cosDigree
        let pointAO2 = CGPoint(x: pointO.x - tempSinDigree, y: pointO.y - tempCosDigree)
        let pointOD1 = CGPoint(x: pointO.x + 2*offset2*sinDigree, y: pointO.y + 2*offset2*cosDigree)
        let pointOD2 = CGPoint(x: pointD.x - offset2*sinDigree, y: pointD.y - offset2*cosDigree)
        
        let pointCP1 = CGPoint(x: pointC.x - offset2*sinDigree, y: pointC.y - offset2*cosDigree)
        let pointCP2 = CGPoint(x: pointP.x + 2*offset2*sinDigree, y: pointP.y + 2*offset2*cosDigree)
        
        let pointPB1 = CGPoint(x: pointP.x - tempSinDigree, y: pointP.y - tempCosDigree)
        let pointPB2 = CGPoint(x: pointB.x + offset1*sinDigree, y: pointB.y + offset1*cosDigree)
        
        
        let cutePath = UIBezierPath()
        
        cutePath.move(to: pointB)
        cutePath.addCurve(to: pointE, controlPoint1: pointBE1, controlPoint2: pointBE2)
        cutePath.addCurve(to: pointA, controlPoint1: pointEA1, controlPoint2: pointEA2)
        cutePath.addCurve(to: pointO, controlPoint1: pointAO1, controlPoint2: pointAO2)
        cutePath.addCurve(to: pointD, controlPoint1: pointOD1, controlPoint2: pointOD2)
        
        cutePath.addCurve(to: pointF, controlPoint1: pointDF1, controlPoint2: pointDF2)
        cutePath.addCurve(to: pointC, controlPoint1: pointFC1, controlPoint2: pointFC2)
        cutePath.addCurve(to: pointP, controlPoint1: pointCP1, controlPoint2: pointCP2)
        cutePath.addCurve(to: pointB, controlPoint1: pointPB1, controlPoint2: pointPB2)
        
        shapeLayer?.path = cutePath.cgPath
        shapeLayer?.fillColor = fillColorForCute.cgColor
        self.layer.insertSublayer(shapeLayer!, below: prototypeView.layer)
    }
    

//    func explosion(centerPint: CGPoint, radius: CGFloat) {
//        var imageArr = [UIImage]()
//        for i in 1...6 {
//            if let image = UIImage(named: "red_dot_image_\(i)") {
//                imageArr.append(image)
//            }
//        }
//        let imageView = UIImageView()
//        imageView.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
//        imageView.center = centerPint
//        imageView.animationImages = imageArr
//        imageView.animationDuration = 0.25
//        imageView.animationRepeatCount = 1
//        imageView.startAnimating()
//        self.addSubview(imageView)
//
//        self.perform(#selector(explosionComplete), with: nil, afterDelay: 0.25, inModes: [.default])
//    }
//
//    @objc func explosionComplete() {
//        touchView?.isHidden = true
//        self.removeFromSuperview()
//    }
    
    

    func springBack(view: UIView, point: CGPoint) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            view.center = point
        }) { finished in
            if finished {
                self.touchView?.isHidden = false
                self.isUserInteractionEnabled = false
                view.removeFromSuperview()
                self.removeFromSuperview()
            }
        }
    }
    
    func getImageFrom(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
