

import UIKit

extension UIImage {
    
    func shareExtensionCompressionImage(_ maxSizeKB: CGFloat = 250, size: CGSize? = nil) -> UIImage? {
        guard let data = self.shareExtensionCompressionImageData(maxSizeKB, size: size) else { return nil }
        return UIImage(data: data)
    }
    

    func shareExtensionCompressionImageData(_ maxSizeKB: CGFloat = 250, size: CGSize? = nil) -> Data? {
        
        guard let newImage = self.shareExtensionResizeImageSize(with: size) else { return nil }
      
        var resizeRate: CGFloat = 0.8
        guard var originImageData = newImage.jpegData(compressionQuality: resizeRate) else { return nil }
        //UIImageJPEGRepresentation(newImage,CGFloat(resizeRate)) else { return nil }
        var sizeOriginKB: CGFloat = CGFloat((originImageData.count)) / 1024.0
        while sizeOriginKB > maxSizeKB && resizeRate > 0.1 {
            guard let imageData = newImage.jpegData(compressionQuality: resizeRate) else { return nil }
            originImageData = imageData
            sizeOriginKB = CGFloat(imageData.count) / 1024.0
            resizeRate -= 0.15
        }
        return originImageData
    }
    

    func shareExtensionResizeImageSize(with size: CGSize?) -> UIImage? {
        let resizeSize = size ?? CGSize(width: 640, height: 1280)
        
        let width = self.size.width
        let height = self.size.height
        let scale = width/height
        var sizeChange = CGSize()
        
        if width <= resizeSize.width && height <= resizeSize.height {
            return self
        } else if width > resizeSize.width || height > resizeSize.height {
            
            if scale <= 2 && scale >= 1 {
                let changedWidth: CGFloat = resizeSize.width
                let changedheight: CGFloat = changedWidth / scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if scale >= 0.5 && scale <= 1 {
                
                let changedheight: CGFloat = resizeSize.height
                let changedWidth: CGFloat = changedheight * scale
                sizeChange = CGSize(width: changedWidth, height: changedheight)
                
            } else if width > 640 && height > resizeSize.height {
                
                if scale > 2 {
                    
                    let changedheight: CGFloat = resizeSize.height
                    let changedWidth: CGFloat = changedheight * scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                } else if scale < 0.5 {
                    
                    let changedWidth: CGFloat = resizeSize.width
                    let changedheight: CGFloat = changedWidth / scale
                    sizeChange = CGSize(width: changedWidth, height: changedheight)
                    
                }
            } else {
                return self
            }
        }
        debugPrint(sizeChange)
        
        UIGraphicsBeginImageContext(sizeChange)
        self.draw(in: CGRect.init(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
        guard let resizedImg = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return resizedImg
    }
    
}

