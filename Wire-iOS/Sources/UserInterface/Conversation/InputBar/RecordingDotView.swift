// 


import UIKit

 final class RecordingDotView: UIView {
    
    init() {
        super.init(frame: CGRect.zero)
        
        backgroundColor = .vividRed
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.width / 2
    }
    
    var animating: Bool = false {
        didSet {
            if oldValue == animating {
                return
            }
            
            if animating {
                self.startAnimation()
            }
            else {
                self.stopAnimation()
            }
        }
    }
    
    fileprivate func startAnimation() {
        self.alpha = 0
        delay(0.15) { 
            UIView.animate(withDuration: 0.55, delay: 0, options: [.autoreverse, .repeat], animations: {
                self.alpha = 1
                }, completion: .none)
        }
    }
    
    fileprivate func stopAnimation() {
        self.layer.removeAllAnimations()
        self.alpha = 1
    }
}
