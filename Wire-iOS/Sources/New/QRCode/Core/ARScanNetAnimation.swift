

import Foundation

class ARScanNetAnimation: UIImageView {
    
    var isAnimationing = false
    var animationRect = CGRect.zero
    
    init() {
        super.init(frame: animationRect)
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public static func instance() -> ARScanNetAnimation {
        return ARScanNetAnimation()
    }
    
    func startAnimating(parentView: UIView) {
        self.image = UIImage.init(named: "qrcode_scan_full_net")
        parentView.addSubview(self)
        self.animationRect = parentView.bounds
        
        isHidden = false
        
        isAnimationing = true
        
        if image != nil {
            stepAnimation()
        }
    }
    
    @objc func stepAnimation() {
        guard isAnimationing else {
            return
        }
        var frame = animationRect
        
        let hImg = image!.size.height * animationRect.size.width / image!.size.width
        
        frame.origin.y -= hImg
        frame.size.height = hImg
        self.frame = frame
        
        alpha = 0.0
        
        UIView.animate(withDuration: 1.2, animations: {
            self.alpha = 1.0
            
            var frame = self.animationRect
            let hImg = self.image!.size.height * self.animationRect.size.width / self.image!.size.width
            
            frame.origin.y += (frame.size.height - hImg)
            frame.size.height = hImg
            
            self.frame = frame
            
        }, completion: { _ in
            self.perform(#selector(ARScanNetAnimation.stepAnimation), with: nil, afterDelay: 0.3)
        })
    }
    
    func stopStepAnimating() {
        isHidden = true
        isAnimationing = false
    }
}
