

import Foundation
import Lottie


class WRLottieAnimateView: UIView {
    
    private let animationView = AnimationView()
      
    // name: JSON 
    init(name: String) {
        super.init(frame: .zero)
        let animation = Animation.named(name)
        animationView.animation = animation
        setupViews()
        
    }
    
    func play(with loopMode: Lottie.LottieLoopMode = .playOnce) {
        animationView.play()
        animationView.loopMode = loopMode
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        animationView.contentMode = .scaleAspectFit
        self.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.animationView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.animationView.topAnchor.constraint(equalTo: self.topAnchor),
            self.animationView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.animationView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}
