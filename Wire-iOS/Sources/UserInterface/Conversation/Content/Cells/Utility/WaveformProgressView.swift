

import UIKit
import Cartography

 private class WaveformBarsView: UIView {
    
    var samples : [Float] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var barColor : UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.contentMode = .redraw;
    }
    
    override fileprivate func draw(_ rect: CGRect) {
        guard let c = UIGraphicsGetCurrentContext()  else { return }
        
        c.clear(self.bounds);
        self.backgroundColor?.setFill();
        c.fill(rect);
        
        if samples.isEmpty {
            return
        }
        
        let barWidth : CGFloat = 2
        let minHeight : CGFloat = 1
        let barspacing : CGFloat = 1
        let stepSpacing = barWidth + barspacing
        let numbersOfBars = Int((rect.width + barspacing) / stepSpacing)
        
        for i in 0..<numbersOfBars {
            let loudness = samples[Int((Float(i) / Float(numbersOfBars)) * Float(samples.count))]
            let rect = CGRect(x: CGFloat(i) * stepSpacing, y: rect.height / 2, width: barWidth, height: max(minHeight, rect.height * CGFloat(loudness) * 0.5))
            c.addRect(rect)
        }
        
        let bars = c.path
        
        c.translateBy(x: 0, y: rect.height)
        c.scaleBy(x: 1, y: -1)
        c.addPath(bars!)
        
        barColor.setFill()
        c.fillPath()
    }
}

class WaveformProgressView: UIView {
    
    fileprivate let backgroundWaveform = WaveformBarsView()
    fileprivate let foregroundWaveform = WaveformBarsView()
    fileprivate var maskShape = CAShapeLayer()
    
    var samples : [Float] = [] {
        didSet {
            backgroundWaveform.samples = samples
            foregroundWaveform.samples = samples
        }
    }
    
    var barColor : UIColor = UIColor.gray {
        didSet {
            backgroundWaveform.barColor = barColor
        }
    }
    
    var highlightedBarColor : UIColor = UIColor.accent() {
        didSet {
            foregroundWaveform.barColor = highlightedBarColor
        }
    }
    
    var progress : Float = 0.0 {
        didSet {
            setProgress(progress, animated: false)
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            backgroundWaveform.backgroundColor = backgroundColor
            foregroundWaveform.backgroundColor = backgroundColor
        }
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.width * CGFloat(progress), height: self.bounds.height)).cgPath
        
        if (animated) {
            let animation = CABasicAnimation(keyPath: "path")
            animation.fromValue = maskShape.path
            animation.toValue = path
            animation.duration = 0.25
            animation.timingFunction = CAMediaTimingFunction(name: .linear)
            animation.fillMode = .forwards
            maskShape.add(animation, forKey: animation.keyPath)
        }
        
        maskShape.path = path
    }
    
    override var bounds: CGRect {
        didSet {
            maskShape.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.bounds.width * CGFloat(progress), height: self.bounds.height)).cgPath
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        maskShape.fillColor = UIColor.white.cgColor
        backgroundWaveform.backgroundColor = UIColor.clear
        backgroundWaveform.barColor = UIColor.gray
        backgroundWaveform.translatesAutoresizingMaskIntoConstraints = false
        foregroundWaveform.backgroundColor = UIColor.clear
        foregroundWaveform.barColor = UIColor.accent()
        foregroundWaveform.translatesAutoresizingMaskIntoConstraints = false
        foregroundWaveform.layer.mask = maskShape
        
        addSubview(backgroundWaveform)
        addSubview(foregroundWaveform)
        
        constrain(backgroundWaveform, foregroundWaveform) { backgroundWaveform, foregroundWaveform in
            backgroundWaveform.edges == backgroundWaveform.superview!.edges
            foregroundWaveform.edges == backgroundWaveform.superview!.edges
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
