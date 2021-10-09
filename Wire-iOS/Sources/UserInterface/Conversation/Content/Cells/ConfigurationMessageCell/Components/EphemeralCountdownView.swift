
import Foundation

class EphemeralCountdownView: UIView {
    
    fileprivate let destructionCountdownView: DestructionCountdownView = DestructionCountdownView()
    fileprivate let containerView =  UIView()
    fileprivate var timer: Timer?
    
    var message: ZMConversationMessage? = nil
    
    init() {
        super.init(frame: .zero)
        
        addSubview(destructionCountdownView)
        
        destructionCountdownView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            destructionCountdownView.centerXAnchor.constraint(equalTo: centerXAnchor),
            destructionCountdownView.topAnchor.constraint(equalTo: topAnchor),
            destructionCountdownView.bottomAnchor.constraint(equalTo: bottomAnchor),
            destructionCountdownView.widthAnchor.constraint(equalToConstant: 10),
            destructionCountdownView.heightAnchor.constraint(equalToConstant: 10),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            stopCountDown()
        }
    }
    
    func startCountDown() {
        stopCountDown()
        
        guard !isHidden else {
            return
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateCountdown()
        }
    }
    
    func stopCountDown() {
        destructionCountdownView.stopAnimating()
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    fileprivate func updateCountdown() {
        guard let destructionDate = message?.destructionDate else {
            return
        }
        
        let duration = destructionDate.timeIntervalSinceNow
        
        if !destructionCountdownView.isAnimatingProgress && duration >= 1, let progress = message?.countdownProgress {
            destructionCountdownView.startAnimating(duration: duration, currentProgress: CGFloat(progress))
        }
    }
    
}
