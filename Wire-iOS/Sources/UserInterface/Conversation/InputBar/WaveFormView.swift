

import UIKit
import Cartography

final class WaveFormView: UIView {

    fileprivate let visualizationView = SCSiriWaveformView()
    fileprivate let leftGradient = GradientView()
    fileprivate let rightGradient = GradientView()
    
    fileprivate var leftGradientWidthConstraint: NSLayoutConstraint?
    fileprivate var rightGradientWidthConstraint: NSLayoutConstraint?
    
    var gradientWidth: CGFloat = 25 {
        didSet {
            leftGradientWidthConstraint?.constant = gradientWidth
            rightGradientWidthConstraint?.constant = gradientWidth
        }
    }
    
    var gradientColor: UIColor = .dynamic(scheme: .barBackground) {
        didSet {
            updateWaveFormColor()
        }
    }
    
    var color: UIColor = .white {
        didSet { visualizationView.waveColor = color }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        configureViews()
        updateWaveFormColor()
        createConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWithLevel(_ level: Float) {
        visualizationView.update(withLevel: level)
    }
    
    fileprivate func configureViews() {
        [visualizationView, leftGradient, rightGradient].forEach(addSubview)
        
        visualizationView.primaryWaveLineWidth = 1
        visualizationView.secondaryWaveLineWidth = 0.5
        visualizationView.numberOfWaves = 4
        visualizationView.waveColor = .accent()
        visualizationView.backgroundColor = UIColor.clear
        visualizationView.phaseShift = -0.3
        visualizationView.frequency = 1.7
        visualizationView.density = 10
        visualizationView.update(withLevel: 0) // Make sure we don't show any waveform
        
        let (midLeft, midRight) = (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        leftGradient.setStartPoint(midLeft, endPoint: midRight, locations: [0, 1])
        rightGradient.setStartPoint(midRight, endPoint: midLeft, locations: [0, 1])
    }
    
    fileprivate func createConstraints() {
        constrain(self, visualizationView, leftGradient, rightGradient) { view, visualizationView, leftGradient, rightGradient in
            visualizationView.edges == view.edges
            align(top: view, leftGradient, rightGradient)
            align(bottom: view, leftGradient, rightGradient)
            view.left == leftGradient.left
            view.right == rightGradient.right
            leftGradientWidthConstraint = leftGradient.width == gradientWidth
            rightGradientWidthConstraint = rightGradient.width == gradientWidth
        }
    }
    
    fileprivate func updateWaveFormColor() {
        let clearGradientColor = gradientColor.withAlphaComponent(0)
        var leftColors = [gradientColor, clearGradientColor].map { $0.cgColor }
        
        if #available(iOS 13.0, *) {
            traitCollection.performAsCurrent {
                leftColors = [gradientColor, clearGradientColor].map { $0.cgColor }
            }
        }
            
        leftGradient.gradientLayer.colors = leftColors
        rightGradient.gradientLayer.colors = leftColors
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        userInterfaceStyleDidChange(previousTraitCollection) { [weak self] _ in
            self?.updateWaveFormColor()
        }
    }
}
