
import Foundation
import Cartography
import FLAnimatedImage

class ImageResourceView: FLAnimatedImageView {
    
    fileprivate var loadingView = ThreeDotsLoadingView()
    
    /// This token is changes everytime the cell is re-used. Useful when performing
    /// asynchronous tasks where the cell might have been re-used in the mean time.
    fileprivate var reuseToken = UUID()
    fileprivate var imageResourceInternal: ImageResource? = nil
    
    public var imageSizeLimit: ImageSizeLimit = .none
    public var imageResource: ImageResource? {
        set {
            setImageResource(newValue)
        }
        get {
            return imageResourceInternal
        }
    }
    
    public func setImageResource(_ imageResource: ImageResource?, hideLoadingView: Bool = false, completion: (() -> Void)? = nil) {
        let token = UUID()
        mediaAsset = nil

        imageResourceInternal = imageResource
        reuseToken = token
        loadingView.isHidden = hideLoadingView || loadingView.isHidden || imageResource == nil

        guard let imageResource = imageResource, imageResource.cacheIdentifier != nil else {
            loadingView.isHidden = true
            completion?()
            return
        }
        
        imageResource.fetchImage(sizeLimit: imageSizeLimit, completion: { [weak self] (mediaAsset, cacheHit) in
            guard token == self?.reuseToken, let `self` = self else { return }
            
            let update = {
                self.loadingView.isHidden = hideLoadingView || mediaAsset != nil
                self.mediaAsset = mediaAsset
                completion?()
            }
            
            if cacheHit || ProcessInfo.processInfo.isRunningTests {
                update()
            } else {
                UIView.transition(with: self, duration: 0.15, options: .transitionCrossDissolve, animations: update)
            }
        })
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.loadingView.accessibilityIdentifier = "loading"
        
        addSubview(loadingView)
        
        constrain(self, loadingView) { containerView, loadingView in
            loadingView.center == containerView.center
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
