//
//  UIImage+save.swift
//  Wire-iOS
//


import Foundation

extension UIImage {

    public class func saveImageData(with imageData: Data) -> String? {
        let img = UIImage.init(data: imageData)
        return img?.saveImage()
    }
    
    public func saveImage() -> String? {
        guard let compressionImgData = self.compressionImageData() else { return nil }
        let imageName = compressionImgData.md5 + ".jpg"
        let imagePath = NSTemporaryDirectory().appendingPathComponent("/localCache" + imageName)
        if !FileManager.default.fileExists(atPath: imagePath) {
            try? compressionImgData.write(to: URL(fileURLWithPath: imagePath))
        }
        return imagePath
    }
    
    public class func getImagePath(with imagePath: String) -> String? {
        let imgNames = imagePath.components(separatedBy: "localCache")
        if imgNames.count == 2 {
            return NSTemporaryDirectory().appendingPathComponent("/localCache" + imgNames.last!)
        } else {
            return imagePath
        }
    }
}
