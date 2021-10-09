
import Foundation
import UIKit

final class ImageContentView: UIView {
    
    var imageView = ImageResourceView()
    var imageAspectConstraint: NSLayoutConstraint?
    var imageWidthConstraint: NSLayoutConstraint

    var mediaAsset: MediaAsset? {
        imageView.mediaAsset
    }

    init() {
        imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 140)

        super.init(frame: .zero)
        
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageWidthConstraint.priority = .defaultLow

        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageWidthConstraint,
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with resource: PreviewableImageResource, completionHandler: (() -> Void)? = nil) {
        updateAspectRatio(for: resource)
        imageView.setImageResource(resource, completion: completionHandler)
    }

    private func updateAspectRatio(for resource: PreviewableImageResource) {
        let contentSize = resource.contentSize
        imageAspectConstraint.apply(imageView.removeConstraint)
        let imageAspectMultiplier = contentSize.width == 0 ? 1 : (contentSize.height / contentSize.width)
        imageAspectConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: imageAspectMultiplier)
        imageAspectConstraint?.isActive = true

        imageWidthConstraint.constant = contentSize.width
        imageView.contentMode = resource.contentMode
    }

}
