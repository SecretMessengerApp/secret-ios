
import FLAnimatedImage

protocol MediaAsset: AnyObject {
    var imageData: Data? { get }
    var size: CGSize { get }
    var isGIF: Bool { get }
    var isTransparent: Bool { get }
}


extension MediaAsset {
    var imageView: MediaAssetView {
        if isGIF {
            let animatedImageView = FLAnimatedImageView()
            animatedImageView.animatedImage = self as? FLAnimatedImage
            
            return animatedImageView
        } else {
            return UIImageView(image: (self as? UIImage)?.downsized())
        }
    }

}


protocol MediaAssetView: UIView {
    var mediaAsset: MediaAsset? { get set }
}

extension MediaAssetView where Self: UIImageView {
    var mediaAsset: MediaAsset? {
        get {
            return image
        }
        set {
            if newValue == nil {
                image = nil
            } else if newValue?.isGIF == false {
                image = (newValue as? UIImage)?.downsized()
            }
        }
    }
}

extension MediaAssetView where Self: FLAnimatedImageView {
    var mediaAsset: MediaAsset? {
        get {
            return animatedImage ?? image
        }
        
        set {
            if let newValue = newValue {
                if newValue.isGIF == true {
                    animatedImage = newValue as? FLAnimatedImage
                } else {
                    image = (newValue as? UIImage)?.downsized()
                }
            } else {
                image = nil
                animatedImage = nil
            }
        }
    }
}

extension FLAnimatedImage: MediaAsset {
    var imageData: Data? {
        return data
    }
    
    var isGIF: Bool {
        return true
    }
    
    var isTransparent: Bool {
        return false
    }
}


extension UIImageView: MediaAssetView {
    
    var imageData: Data? {
        get {
            return image?.imageData
        }
        
        set {
            if let imageData = newValue {
                image = UIImage(data: imageData)
            }
        }
    }
}



