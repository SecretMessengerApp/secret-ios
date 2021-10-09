
import Foundation

 class PreviewHeightCalculator: NSObject {
    
    static let standardCellHeight : CGFloat = 200.0
    static let compressedCellHeight : CGFloat = 160.0
    static let videoViewHeight : CGFloat = 160.0
    
    static func heightForImage(_ image: UIImage?) -> CGFloat {
        var height : CGFloat = 0.0
        if let image = image, image.size.height < standardCellHeight {
            height = image.size.height
        } else {
            height = standardCellHeight
        }
        
        return calculateFinalHeight(for: height)
    }
    
    static func compressedSizeForView(_ view: UIView) -> CGFloat {
        return view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height;
    }
    
    static func heightForVideo() -> CGFloat {
        return calculateFinalHeight(for: videoViewHeight)
    }
    
    private static func calculateFinalHeight(for height: CGFloat) -> CGFloat {
        return min((UIScreen.main.isCompact ? compressedCellHeight : standardCellHeight), height)
    }

}
