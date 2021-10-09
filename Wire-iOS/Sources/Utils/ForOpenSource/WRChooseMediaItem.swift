//
//  WRChooseMediaItem.swift
//  Wire-iOS
//

import Foundation
import Photos
import YPImagePicker

struct WRChooseMediaItem {
    
    enum MediaType {
        case photo(image: UIImage, data: Data)
        case video(thumbnail: UIImage, url: URL, duration: TimeInterval, naturalSize: String)
    }

    public let type: MediaType
    public let asset: PHAsset?
    
    init(items: YPMediaItem) {
        switch items {
        case .photo(p: let photo):
            self.type = .photo(image: photo.image, data: photo.data)
            self.asset = photo.asset
        case .video(v: let video):
            self.type = .video(thumbnail: video.thumbnail, url: video.url, duration: video.duration, naturalSize: video.naturalSize)
            self.asset = video.asset
        }
    }
    
    init(mediaDuration: TimeInterval, videoPath: String, thumbnailPath: String, naturalSize: String) {
        self.type = .video(thumbnail: UIImage.init(contentsOfFile: thumbnailPath) ?? UIImage(),
                           url: URL.init(fileURLWithPath: videoPath),
                           duration: mediaDuration,
                           naturalSize: naturalSize)
        self.asset = nil
    }
}
