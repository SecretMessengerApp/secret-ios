
import UIKit
import SDWebImage
import FLAnimatedImage
import SSticker

private var aniPlaceholder: UIImage? = nil

class AnimatedView: UIView {
    private lazy var tgsImageView: StickerAnimatedImageView = {
        let imageview = StickerAnimatedImageView(frame: .zero)
        imageview.contentMode = .scaleAspectFit
        imageview.isUserInteractionEnabled = false
        return imageview
    }()
    
    private lazy var gifImageView: FLAnimatedImageView = {
        let imageview = FLAnimatedImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.isUserInteractionEnabled = false
        return imageview
    }()
    
    private lazy var imageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        imageview.isUserInteractionEnabled = false
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(gifImageView)
        addSubview(tgsImageView)
        addSubview(imageView)
        gifImageView.secret.pin()
        tgsImageView.secret.pin()
        imageView.secret.pin()
    }
    
    public func set(_ url: String, size: CGSize = CGSize(width: 120, height: 120)) {
        let defaultImage = placeholder(size: size)

        if url.hasSuffix("tgs"), let url = URL(string: url) {
            gifImageView.isHidden = true
            tgsImageView.isHidden = false
            imageView.isHidden = true
            tgsImageView.setSecretAnimation(url, size, defaultImage)
            return
        }

        if url.hasSuffix("gif"), let url = URL(string: url) {
            gifImageView.sd_setImage(with: url, placeholderImage: defaultImage, completed: nil)
            gifImageView.isHidden = false
            tgsImageView.isHidden = true
            imageView.isHidden = true
        } else if url.hasSuffix("jpg") || url.hasSuffix("png") {
            gifImageView.isHidden = true
            tgsImageView.isHidden = true
            imageView.isHidden = false
            imageView.sd_setImage(with: URL(string: url),placeholderImage: defaultImage, completed: nil)
        } else {
            gifImageView.isHidden = false
            tgsImageView.isHidden = true
            imageView.isHidden = true
            let data = SDImageCache.shared.diskImageData(forKey: url)
            gifImageView.animatedImage = FLAnimatedImage(animatedGIFData: data)
        }
    }
    
    private func makePlacehoder(size: CGSize, radius: CGFloat = 9.0) -> UIImage? {
        let render = UIGraphicsImageRenderer(size: size)
        return render.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: radius)
            UIColor.dynamic(scheme: .placeholder).setFill()
            path.fill()
        }
    }

    private func placeholder(size: CGSize) -> UIImage? {
        if aniPlaceholder == nil {
            aniPlaceholder = makePlacehoder(size: size)
        }
        
        return aniPlaceholder
    }
}
