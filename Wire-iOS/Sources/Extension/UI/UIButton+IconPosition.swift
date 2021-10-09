//
//  UIButton+IconPosition.swift
//  Wire-iOS
//


import Foundation

public extension UIButton {
    
    enum ImagePosition {
        case left
        case right
        case top
        case bottom  
    }
    public func imagePostion(postion: ImagePosition, spacing: CGFloat) {
        guard let _ = self.imageView?.image else { return }
        let imageWith = self.imageView?.image?.size.width
        let imageHeight = self.imageView?.image?.size.height
        let labelSize = titleLabel?.attributedText?.size()
        let imageOffsetX = (imageWith! + (labelSize?.width)!) / 2 - imageWith! / 2
        let imageOffsetY = imageHeight! / 2 + spacing / 2
        let labelOffsetX = (imageWith! + (labelSize?.width)! / 2) - (imageWith! + (labelSize?.width)!) / 2
        let labelOffsetY = (labelSize?.height)! / 2 + spacing / 2
        
        switch postion {
        case .left:
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
        case .right:
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: (labelSize?.width)! + spacing/2, bottom: 0, right: -((labelSize?.width)! + spacing/2))
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageHeight! + spacing/2), bottom: 0, right: imageHeight! + spacing/2)
        case .top:
            self.imageEdgeInsets = UIEdgeInsets(top: -imageOffsetY, left: imageOffsetX, bottom: imageOffsetY, right: -imageOffsetX)
            self.titleEdgeInsets = UIEdgeInsets(top: labelOffsetY, left: -labelOffsetY - 5, bottom: -labelOffsetY, right: labelOffsetX)
        case .bottom:
            self.imageEdgeInsets = UIEdgeInsets(top: imageOffsetY, left: imageOffsetX, bottom: -imageOffsetY, right: -imageOffsetX)
            self.titleEdgeInsets = UIEdgeInsets(top: -labelOffsetY, left: -labelOffsetX, bottom: labelOffsetY, right: labelOffsetX)
            
        }
        
    }
    
    func verticalImageAndTitle(_ spacing: CGFloat) {
        let imageSize: CGSize? = imageView?.frame.size
        var titleSize: CGSize? = titleLabel?.frame.size
        let textSize: CGSize? = titleLabel?.text?.size(withAttributes: [NSAttributedString.Key.font: titleLabel?.font ?? 0])
        let frameSize = CGSize(width: CGFloat(ceilf(Float((textSize?.width)!))), height: CGFloat( ceilf(Float((textSize?.height)!))))
        if (titleSize?.width ?? 0.0) + 0.5 < frameSize.width {
            titleSize?.width = frameSize.width
        }
        let totalHeight: CGFloat = (imageSize?.height ?? 0.0) + (titleSize?.height ?? 0.0) + spacing
        imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - (imageSize?.height ?? 0.0)), left: 0.0, bottom: 0.0, right: -(titleSize?.width ?? 0.0))
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageSize?.width ?? 0.0), bottom: -(totalHeight - (titleSize?.height ?? 0.0)), right: 0)
    }
    
    
}
