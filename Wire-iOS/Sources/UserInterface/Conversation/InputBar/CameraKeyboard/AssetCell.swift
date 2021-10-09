

import Foundation
import Photos
import Cartography

open class AssetCell: UICollectionViewCell {
    

    enum SelectedState {
        case hidden
        case none
        case sort(number: Int)
    }
    let selectedMarkBtn = UIButton()
    var selectedStateResponse: ((Bool) -> ())? = nil
    var selectedState: SelectedState = .hidden {
        didSet {
            switch selectedState {
            case .hidden:
                selectedMarkBtn.isHidden = true
            case .none:
                selectedMarkBtn.isHidden = false
                selectedMarkBtn.backgroundColor = UIColor(hex: 0xAAAAAA, alpha: 0.4)
                selectedMarkBtn.layer.borderColor = UIColor.white.cgColor
                selectedMarkBtn.layer.borderWidth = 1
                selectedMarkBtn.setTitle("", for: .normal)
            case .sort(let number):
                selectedMarkBtn.isHidden = false
                selectedMarkBtn.backgroundColor = UIColor(hex: 0x0A77FD)
                selectedMarkBtn.layer.borderWidth = 0
                selectedMarkBtn.setTitle("\(number)", for: .normal)
            }
        }
    }
    
    let imageView = UIImageView()
    let durationView = UILabel()
    
    var imageRequestTag: PHImageRequestID = PHInvalidImageRequestID
    var representedAssetIdentifier: String!
    var manager: ImageManagerProtocol!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.clipsToBounds = true
        
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.contentView.addSubview(self.imageView)
        
        self.durationView.textAlignment = .center
        self.durationView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        self.durationView.textColor = UIColor.white
        self.durationView.font = FontSpec(.small, .light).font!
        self.contentView.addSubview(self.durationView)
        
        self.selectedMarkBtn.isHidden = true
        self.selectedMarkBtn.clipsToBounds = true
        self.selectedMarkBtn.cornerRadius = 10
        self.selectedMarkBtn.backgroundColor = UIColor.red
        self.selectedMarkBtn.layer.borderColor = UIColor.white.cgColor
        self.selectedMarkBtn.layer.borderWidth = 1
        self.selectedMarkBtn.titleLabel?.font = UIFont.init(12, .regular)
        self.selectedMarkBtn.addTarget(self, action: #selector(selectedAction), for: .touchUpInside)
        self.contentView.addSubview(self.selectedMarkBtn)
        
        constrain(self.contentView, self.imageView, self.durationView, self.selectedMarkBtn) { contentView, imageView, durationView, selectedMarkBtn in
            imageView.edges == contentView.edges
            durationView.bottom == contentView.bottom
            durationView.left == contentView.left
            durationView.right == contentView.right
            durationView.height == 20
            
            selectedMarkBtn.width == 20
            selectedMarkBtn.height == selectedMarkBtn.width
            selectedMarkBtn.top == contentView.top + 8
            selectedMarkBtn.right == contentView.right - 8
        }
    }
    
    @objc func selectedAction(sender: UIButton) {
        if case .none = self.selectedState {
            self.selectedStateResponse?(true)
        } else {
            self.selectedStateResponse?(false)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static let imageFetchOptions: PHImageRequestOptions = {
        let options: PHImageRequestOptions = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.resizeMode = .fast
        options.isSynchronous = false
        return options
    }()
    
    var asset: PHAsset? {
        didSet {
            self.imageView.image = nil

            if self.imageRequestTag != PHInvalidImageRequestID {
                manager.cancelImageRequest(self.imageRequestTag)
                self.imageRequestTag = PHInvalidImageRequestID
            }

            guard let asset = self.asset else {
                self.durationView.text = ""
                self.durationView.isHidden = true
                return
            }

            let maxDimensionRetina = max(self.bounds.size.width, self.bounds.size.height) * (self.window ?? UIApplication.shared.keyWindow!).screen.scale

            representedAssetIdentifier = asset.localIdentifier
            imageRequestTag = manager.requestImage(for: asset,
                                                   targetSize: CGSize(width: maxDimensionRetina, height: maxDimensionRetina),
                                                   contentMode: .aspectFill,
                                                   options: type(of: self).imageFetchOptions,
                                                   resultHandler: { [weak self] result, info -> Void in
                                                    guard let `self` = self,
                                                        self.representedAssetIdentifier == asset.localIdentifier
                                                        else { return }
                                                    self.imageView.image = result
            })

            if asset.mediaType == .video {
                let duration = Int(ceil(asset.duration))

                let (seconds, minutes) = (duration % 60, duration / 60)
                self.durationView.text = String(format: "%d:%02d", minutes, seconds)
                self.durationView.isHidden = false
            }
            else {
                self.durationView.text = ""
                self.durationView.isHidden = true
            }
        }
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        self.asset = .none
    }
}
