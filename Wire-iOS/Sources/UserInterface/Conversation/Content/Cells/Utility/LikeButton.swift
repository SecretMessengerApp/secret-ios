
import Foundation
import Cartography

final class LikeButton: IconButton {
    static var normalColor: UIColor {
        return UIColor.from(scheme: .textDimmed)
    }

    static var selectedColor: UIColor {
        return UIColor(for: .vividRed)
    }

    func setSelected(_ selected: Bool, animated: Bool) {
        // Do not animate changes if the state does not change
        guard selected != self.isSelected else {
            return
        }
        
        if animated {
            guard let imageView = self.imageView else {
                return
            }
            
            let prevState: UIControl.State
            if self.isSelected {
                prevState = .selected
            }
            else {
                prevState = []
            }

            let currentIcon = icon(for: prevState) ?? (prevState == .selected ? .liked : .like)
            let fakeImageView = UIImageView()
            fakeImageView.setIcon(currentIcon, size: .large, color: self.iconColor(for: prevState) ?? LikeButton.normalColor)
            fakeImageView.frame = imageView.frame
            
            imageView.superview!.addSubview(fakeImageView)

            let selectedIcon = icon(for: prevState) ?? .liked
            let animationImageView = UIImageView()
            animationImageView.setIcon(selectedIcon, size: .large, color: LikeButton.selectedColor)
            animationImageView.frame = imageView.frame
            imageView.superview!.addSubview(animationImageView)

            imageView.alpha = 0
            if selected { // gets like
                animationImageView.alpha = 0.0
                animationImageView.transform = CGAffineTransform(scaleX: 6.3, y: 6.3)
                
                UIView.animate(easing: .easeOutExpo, duration: 0.35, animations: {
                    animationImageView.transform = CGAffineTransform.identity
                })
                
                UIView.animate(easing: .easeOutQuart, duration: 0.35, animations: {
                        animationImageView.alpha = 1
                    }, completion: { _ in
                        animationImageView.removeFromSuperview()
                        fakeImageView.removeFromSuperview()
                        imageView.alpha = 1
                        self.isSelected = selected
                    })
            }
            else {
                
                UIView.animate(easing: .easeInExpo, duration: 0.35, animations: {
                    animationImageView.transform = CGAffineTransform(scaleX: 6.3, y: 6.3)
                })
                
                UIView.animate(easing: .easeInQuart, duration: 0.35, animations: {
                    animationImageView.alpha = 0.0
                    }, completion: { _ in
                        animationImageView.removeFromSuperview()
                        fakeImageView.removeFromSuperview()
                        imageView.alpha = 1
                        self.isSelected = selected
                    })
            }
            
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        else {
            self.isSelected = selected
        }
    }
}
