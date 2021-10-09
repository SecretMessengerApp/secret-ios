

import Foundation

 open class ProgressView: UIView {
    fileprivate var deterministic: Bool? = .none
    fileprivate var progress: Float = 0
    fileprivate var progressView: UIView = UIView()
    fileprivate var spinner: BreathLoadingBar = BreathLoadingBar(animationDuration: 3.0)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    fileprivate func setup() {
        self.progressView.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        self.spinner.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.progressView.frame = self.bounds
        self.spinner.frame = self.bounds
        
        self.addSubview(self.progressView)
        self.addSubview(self.spinner)
        
        self.updateForStateAnimated(false)
        self.updateProgress(false)
        self.progressView.backgroundColor = self.tintColor
        self.spinner.backgroundColor = self.tintColor
    }
    
    open override var tintColor: UIColor? {
        didSet {
            self.progressView.backgroundColor = tintColor
            self.spinner.backgroundColor = tintColor
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.updateProgress(false)
    }
    
    open func setDeterministic(_ determenistic: Bool, animated: Bool) {
        if self.deterministic != .none && self.deterministic == determenistic {
            return
        }
        self.deterministic = determenistic
        self.updateForStateAnimated(animated)
        self.updateProgress(animated)
    }

    open func setProgress(_ progress: Float, animated: Bool) {
        self.progress = progress
        self.updateProgress(animated)
    }

    fileprivate func updateProgress(_ animated: Bool) {
        guard self.progress.isNormal &&
                self.bounds.width != 0 &&
                self.bounds.height != 0 else {
            return
        }
        
        let progress = (self.deterministic ?? false) ? self.progress : 1;
        
        let setBlock = {
            self.progressView.frame = CGRect(x: 0, y: 0, width: CGFloat(progress) * self.bounds.size.width, height: self.bounds.size.height)
        }
        
        if animated {
            UIView.animate(withDuration: 0.35, delay: 0.0, options: [.beginFromCurrentState], animations: setBlock, completion: .none)
        }
        else {
            setBlock()
        }
    }
    
    fileprivate func updateForStateAnimated(_ animated: Bool) {
        if let det = self.deterministic, det {
            self.progressView.isHidden = false
            self.spinner.isHidden = true
            self.spinner.animating = false
        }
        else {
            self.progressView.isHidden = true
            self.spinner.isHidden = false
            self.spinner.animating = true
        }
    }
}
